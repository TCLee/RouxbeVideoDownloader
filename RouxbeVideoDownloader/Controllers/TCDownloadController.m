//
//  TCDownloadController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/22/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadController.h"
#import "NSURL+RouxbeAdditions.h"
#import "TCVideo.h"
#import "TCDownload.h"
#import "TCDownloadQueue.h"

@interface TCDownloadController ()

@property (nonatomic, copy) TCDownloadControllerSuccessBlock successHandler;
@property (nonatomic, copy) TCDownloadControllerFailureBlock failureHandler;

@end

@implementation TCDownloadController

@synthesize downloadQueue = _downloadQueue;

#pragma mark - Download Queue

- (TCDownloadQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[TCDownloadQueue alloc] init];
    }
    return _downloadQueue;
}

#pragma mark - Search and Add Downloads

- (void)addDownloadsWithURL:(NSURL *)theURL
                    success:(TCDownloadControllerSuccessBlock)success
                    failure:(TCDownloadControllerFailureBlock)failure
{
    self.successHandler = success;
    self.failureHandler = failure;

    // Error - Not a valid rouxbe.com URL. Cannot search for videos.
    if (![theURL isValidRouxbeURL]) {
        if (self.failureHandler) {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorUnsupportedURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Examples of valid rouxbe.com URL:\nhttp://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock\nhttp://rouxbe.com/recipes/63-red-pepper-eggplant-confit"}];
            self.failureHandler(error);
        }
        return;
    }

    // URL is OK, so we can begin searching for videos from the URL.
    [self searchVideosWithURL:theURL];
}

/**
 * Search for videos from the given URL. For each video found, calls
 * TCDownloadController::addDownloadForVideo: to create and add a download
 * for the video to the download queue.
 */
- (void)searchVideosWithURL:(NSURL *)theURL
{
    // Completion handler will be called multiple times - once for each
    // video found.
    [TCVideo videosWithURL:theURL completionHandler:^(TCVideo *video, NSError *error) {
        if (video) {
            [self addDownloadForVideo:video];
        } else {
            // Error - An error occured while searching for videos.
            if (self.failureHandler) {
                self.failureHandler(error);
            }
        }
    }];
}

/**
 * Create a download for the given video and add it to the queue.
 */
- (void)addDownloadForVideo:(TCVideo *)video
{
    TCDownload *download = [[TCDownload alloc] initWithVideo:video
                                        downloadDirectoryURL:[self userDownloadDirectoryURL]
                                                 description:video.destinationPathComponent];

    // If directory was successfully created, we add the download to the queue.
    // Otherwise, it's no point starting the download when we cannot write the
    // file to the destination directory.
    if ([self createDirectoryAtURL:[download destinationURL]]) {
        [self.downloadQueue addDownload:download];

        if (self.successHandler) {
            self.successHandler();
        }
    }
}

#pragma mark - File Operations

/**
 * Creates the directory at the given download destination URL.
 *
 * @param destinationURL The URL where the downloaded file will be saved to.
 *
 * @return \c YES if directory was created; \c NO otherwise.
 */
- (BOOL)createDirectoryAtURL:(NSURL *)destinationURL
{
    // Create the directory to contain the downloaded file (if necessary).
    // If directory already exists, nothing will happen.
    NSError *__autoreleasing error = nil;
    BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtURL:destinationURL
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
    // Error - Failed to create destination directory for download.
    if (!directoryCreated) {
        if (self.failureHandler) {
            self.failureHandler(error);
        }
    }

    return directoryCreated;
}

/**
 * Return the user's default Downloads directory or \c nil if not found.
 */
- (NSURL *)userDownloadDirectoryURL
{
    NSURL *directoryURL = [[[NSFileManager defaultManager]
                            URLsForDirectory:NSDownloadsDirectory
                            inDomains:NSUserDomainMask] firstObject];

    NSAssert(directoryURL, @"Could not locate the Downloads directory.");

    return directoryURL;
}

@end
