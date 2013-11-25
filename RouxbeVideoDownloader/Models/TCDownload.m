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

- (id)initWithSourceURL:(NSURL *)sourceURL
         destinationURL:(NSURL *)destinationURL
            description:(NSString *)description
{
    self = [super init];
    if (self) {
        _sourceURL = [sourceURL copy];
        _destinationURL = [destinationURL copy];
        _description = [description copy];

        // All download starts in the paused state.
        // It will move to the running state, when it's added to
        // the download queue.
        _state = TCDownloadStatePaused;
    }
    return self;
}

#pragma mark - Create Downloads from URL

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
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Examples of valid rouxbe.com URL:\n- http://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock\n- http://rouxbe.com/recipes/63-red-pepper-eggplant-confit"}];
            completionHandler(nil, error);
        }
        return;
    }

    // Search for videos from the given URL.
    [TCVideo videosWithURL:theURL completionHandler:^(NSArray *videos, NSError *error) {
        if (videos) {
            // Create a download for each video found.
            [self downloadsWithVideos:videos
                 downloadDirectoryURL:downloadDirectoryURL
                    completionHandler:completionHandler];
        } else {
            // An error occured while searching for videos.
            if (completionHandler) {
                completionHandler(nil, error);
            }
        }
    }];
}

+ (void)downloadsWithVideos:(NSArray *)videos
       downloadDirectoryURL:(NSURL *)downloadDirectoryURL
          completionHandler:(TCDownloadCompletionHandler)completionHandler
{
    NSString *pathComponent =[videos.firstObject destinationPathComponent];
    NSURL *fullPath =[downloadDirectoryURL URLByAppendingPathComponent:pathComponent];
    NSURL *destinationDirectoryURL = [fullPath URLByDeletingLastPathComponent];

    // Create the directory to hold the downloads, if necessary.
    // If failed to create directory, then we can't start the download as there
    // is no place to save the downloads to.
    if (![self createDirectoryAtURL:destinationDirectoryURL
                  completionHandler:completionHandler]) {
        return;
    }

    // Create a download for each video.
    NSMutableArray *downloads = [[NSMutableArray alloc] initWithCapacity:videos.count];
    for (TCVideo *video in videos) {
        NSURL *destinationURL = [downloadDirectoryURL URLByAppendingPathComponent:video.destinationPathComponent];
        TCDownload *download = [[TCDownload alloc] initWithSourceURL:video.sourceURL
                                                      destinationURL:destinationURL
                                                         description:video.destinationPathComponent];
        [downloads addObject:download];
    }

    if (completionHandler) {
        completionHandler(downloads, nil);
    }
}

+ (BOOL)createDirectoryAtURL:(NSURL *)directoryURL
           completionHandler:(TCDownloadCompletionHandler)completionHandler
{
    // Create the directory to contain the downloaded files.
    // If directory already exists, nothing will happen.
    NSError *__autoreleasing error = nil;
    BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
    if (!directoryCreated) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }

    return directoryCreated;
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

        // Activate the speed measure to enable download speed calculations.
        _speedMeasure.active = YES;
    }
    return _speedMeasure;
}

@end
