//
//  TCDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"
#import "TCDownloadPrivate.h"
#import "TCVideo.h"
#import "NSURL+RouxbeAdditions.h"
#import "AFURLConnectionByteSpeedMeasure.h"

@implementation TCDownload

@synthesize progress = _progress;
@synthesize speedMeasure = _speedMeasure;

#pragma mark - Initialize

- (id)initWithVideo:(TCVideo *)video
downloadDirectoryURL:(NSURL *)downloadDirectoryURL
        description:(NSString *)description
{
    self = [super init];
    if (self) {
        _sourceURL = [video.sourceURL copy];
        _destinationURL = [downloadDirectoryURL URLByAppendingPathComponent:video.destinationPathComponent];
        _description = [description copy];

        // All download starts in the paused state.
        // It will move to the running state, when it's added to
        // the download queue.
        _state = TCDownloadStatePaused;
    }
    return self;
}

#pragma mark - Download Progress

- (NSProgress *)progress
{
    if (!_progress) {
        _progress = [[NSProgress alloc] initWithParent:nil
                                              userInfo:nil];

        // Configure NSProgress to create a description string suitable for
        // file downloads.
        _progress.kind = NSProgressKindFile;
        [_progress setUserInfoObject:NSProgressFileOperationKindDownloading
                              forKey:NSProgressFileOperationKindKey];
    }
    return _progress;
}

- (AFURLConnectionByteSpeedMeasure *)speedMeasure
{
    if (!_speedMeasure) {
        _speedMeasure = [[AFURLConnectionByteSpeedMeasure alloc] init];
    }
    return _speedMeasure;
}

#pragma mark - Create Downloads from a URL

+ (void)downloadsWithURL:(NSURL *)theURL
       completionHandler:(TCDownloadCompletionHandler)completionHandler
{
    [self downloadsWithURL:theURL
      downloadDirectoryURL:[self userDownloadsDirectoryURL]
         completionHandler:completionHandler];
}

+ (void)downloadsWithURL:(NSURL *)theURL
    downloadDirectoryURL:(NSURL *)downloadDirectoryURL
       completionHandler:(TCDownloadCompletionHandler)completionHandler
{
    // Error - Not a valid rouxbe.com URL. Cannot search for videos.
    if (![theURL isValidRouxbeURL]) {
        if (completionHandler) {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorUnsupportedURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Examples of valid rouxbe.com URL:\nhttp://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock\nhttp://rouxbe.com/recipes/63-red-pepper-eggplant-confit"}];
            completionHandler(nil, error);
        }
        return;
    }

    // Search for videos from the given URL. For each video found, we'll
    // create a download for it.
    [TCVideo videosWithURL:theURL completionHandler:^(TCVideo *video, NSError *error) {
        if (video) {
            [self createDownloadForVideo:video
                    downloadDirectoryURL:downloadDirectoryURL
                       completionHandler:completionHandler];
        } else {
            // Error - An error occured while searching for videos.
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
}

+ (void)createDownloadForVideo:(TCVideo *)video
          downloadDirectoryURL:(NSURL *)downloadDirectoryURL
             completionHandler:(TCDownloadCompletionHandler)completionHandler
{
    NSURL *destinationURL = [downloadDirectoryURL URLByAppendingPathComponent:video.destinationPathComponent];
    NSURL *destinationDirectoryURL = [destinationURL URLByDeletingLastPathComponent];

    // Create the directory to contain the downloaded file (if necessary).
    // If directory already exists, nothing will happen.
    NSError *__autoreleasing error = nil;
    BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectoryURL
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
    TCDownload *download = nil;

    // Create the download only if destination directory could be created.
    // Otherwise, it's pointless to create the download when we cannot write
    // to the destination URL.
    if (directoryCreated) {
        download = [[TCDownload alloc] initWithVideo:video
                                downloadDirectoryURL:downloadDirectoryURL
                                         description:video.destinationPathComponent];
    }

    if (completionHandler) {
        completionHandler(download, error);
    }
}

#pragma mark - User's Downloads Directory

/**
 * Return the user's default Downloads directory or \c nil if not found.
 */
+ (NSURL *)userDownloadsDirectoryURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [[fileManager URLsForDirectory:NSDownloadsDirectory
                                               inDomains:NSUserDomainMask] firstObject];
    return directoryURL;
}

@end
