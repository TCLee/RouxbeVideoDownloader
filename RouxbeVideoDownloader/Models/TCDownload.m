//
//  TCDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"
#import "TCDownload+TCDownloadQueueAdditions.h"
#import "TCVideo.h"
#import "NSURL+RouxbeAdditions.h"
#import "AFURLConnectionByteSpeedMeasure.h"

@interface TCDownload ()

@property (readwrite, nonatomic, strong) NSURLSessionDownloadTask *task;
@property (readwrite, nonatomic, copy) NSData *resumeData;
@property (readwrite, nonatomic, strong) AFURLConnectionByteSpeedMeasure *speedMeasure;
@property (readwrite, nonatomic, assign) TCDownloadState state;
@property (readwrite, nonatomic, copy) NSError *error;

@end

@implementation TCDownload

@synthesize progress = _progress;

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

        // All download starts in the paused state. It will move to the
        // running state, when a resume message is sent.
        _state = TCDownloadStateSuspended;
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
        _speedMeasure.active = YES;
    }
    return _speedMeasure;
}

- (void)setProgressWithBytesWritten:(int64_t)bytesWritten
                  totalBytesWritten:(int64_t)totalBytesWritten
          totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
                          timestamp:(NSDate *)timestamp
{
    // Re-calculate new average download speed.
    [self.speedMeasure updateSpeedWithDataChunkLength:bytesWritten
                                       receivedAtDate:timestamp];

    // Update the download's progress.
    self.progress.completedUnitCount = totalBytesWritten;
    self.progress.totalUnitCount = totalBytesExpectedToWrite;

    // Update the download's current speed and estimated time to finish.
    [self.progress setUserInfoObject:@(self.speedMeasure.speed)
                              forKey:NSProgressThroughputKey];
    [self.progress setUserInfoObject:@([self.speedMeasure remainingTimeOfTotalSize:totalBytesExpectedToWrite numberOfCompletedBytes:totalBytesWritten])
                              forKey:NSProgressEstimatedTimeRemainingKey];
}

#pragma mark - Controlling Download State

- (void)resume
{
    [self.task resume];
    self.state = TCDownloadStateRunning;
}

- (void)cancel
{
    [self.task cancelByProducingResumeData:^(NSData *resumeData) {
        self.resumeData = resumeData;
        self.state = TCDownloadStateCancelled;
    }];
    self.state = TCDownloadStateCanceling;
}

- (void)setCompletedWithFileURL:(NSURL *)fileURL error:(NSError *)error
{
    if (fileURL) {
        self.state = TCDownloadStateCompleted;
        self.error = nil;
        self.resumeData = nil;
    } else {
        // A cancelled download is also treated as an error by NSURLSession.
        // So, we must differentiate between a cancelled download and an actual
        // failed download.
        self.state = NSURLErrorCancelled == error.code ? TCDownloadStateCancelled : TCDownloadStateFailed;
        self.error = error;
        self.resumeData = self.error.userInfo[NSURLSessionDownloadTaskResumeData];
    }
}

#pragma mark - Progress and State Description

- (NSString *)localizedProgressDescription
{
    switch (self.state) {
        case TCDownloadStateRunning: {
            NSString *progressDescription = [self.progress localizedAdditionalDescription];
            return progressDescription.length > 0 ? progressDescription : @"Waiting for turn...";
        }

        case TCDownloadStateCancelled:
            [self.progress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
            [self.progress setUserInfoObject:nil forKey:NSProgressThroughputKey];
            return [NSString stringWithFormat:@"%@ - %@",
                    NSLocalizedString(@"Stopped", @"Download Stopped"),
                    [self.progress localizedAdditionalDescription]];

        case TCDownloadStateCompleted:
            [self.progress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
            [self.progress setUserInfoObject:nil forKey:NSProgressThroughputKey];
            return [NSString stringWithFormat:@"%@ - %@",
                    NSLocalizedString(@"Completed", @"Download Completed"),
                    [self.progress localizedAdditionalDescription]];

        case TCDownloadStateFailed:
            return [NSString stringWithFormat:@"%@ - %@",
                    NSLocalizedString(@"Failed", @"Download Failed"),
                    [self.error localizedDescription]];

        default:
            return @"";
    }
}

@end
