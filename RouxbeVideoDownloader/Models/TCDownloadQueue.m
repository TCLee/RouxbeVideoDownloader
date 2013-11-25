//
//  TCDownloadQueue.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadQueue.h"
#import "TCDownload.h"
#import "TCDownloadPrivate.h"
#import "AFURLConnectionByteSpeedMeasure.h"

@interface TCDownloadQueue ()

/**
 * The session manager that manages the session for all download tasks.
 */
@property (nonatomic, strong) AFURLSessionManager *sessionManager;

/**
 * The mutable download queue for internal use only.
 */
@property (nonatomic, strong, readonly) NSMutableArray *mutableDownloads;

/**
 * The block object to execute when a download's state or progress has changed.
 */
@property (nonatomic, copy) TCDownloadQueueDownloadStateDidChangeBlock downloadStateDidChange;

@end

@implementation TCDownloadQueue

@synthesize mutableDownloads = _mutableDownloads;

#pragma mark - Initialize

- (id)init
{
    return [self initWithSessionManager:nil];
}

- (id)initWithSessionManager:(AFURLSessionManager *)aSessionManager
{
    self = [super init];
    if (self) {
        // If no session manager is provided, we'll create our own
        // session manager using the default configuration.
        if (!aSessionManager) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            aSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        }

        _sessionManager = aSessionManager;
        [self configureSessionManager:_sessionManager];
    }
    return self;
}

- (void)configureSessionManager:(AFURLSessionManager *)sessionManager
{
    __weak typeof(self)weakSelf = self;

    // TODO: Get the download associated with the task.
    // TODO: Get the index of the download object.
    TCDownload *download = nil;
    NSUInteger downloadIndex = 0;

    [sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSDate *now = [NSDate date];

        dispatch_async(dispatch_get_main_queue(), ^{
            // Re-calculate new average download speed.
            [download.speedMeasure updateSpeedWithDataChunkLength:bytesWritten
                                                   receivedAtDate:now];

            // Update the download's progress.
            download.progress.completedUnitCount = totalBytesWritten;
            download.progress.totalUnitCount = totalBytesExpectedToWrite;

            // Update the download's current speed and estimated time to finish.
            [download.progress setUserInfoObject:@(download.speedMeasure.speed)
                                          forKey:NSProgressThroughputKey];
            [download.progress setUserInfoObject:@([download.speedMeasure remainingTimeOfTotalSize:totalBytesExpectedToWrite numberOfCompletedBytes:totalBytesWritten])
                                          forKey:NSProgressEstimatedTimeRemainingKey];

            if (weakSelf.downloadStateDidChange) {
                weakSelf.downloadStateDidChange(downloadIndex);
            }
        });
    }];
}

#pragma mark - Managing Downloads in the Queue

- (NSUInteger)downloadCount
{
    return self.mutableDownloads.count;
}

- (TCDownload *)downloadAtIndex:(NSUInteger)index
{
    return (TCDownload *)self.mutableDownloads[index];
}

- (void)addDownloads:(NSArray *)downloads
{
    [self.mutableDownloads addObjectsFromArray:downloads];

    __weak typeof(self)weakSelf = self;

    for (TCDownload *download in downloads) {

        // Create a download task for each download object.
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:download.sourceURL];
        NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return download.destinationURL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSUInteger downloadIndex = [weakSelf.mutableDownloads indexOfObject:download];
            if (NSNotFound == downloadIndex) {
                [NSException raise:NSInternalInconsistencyException
                            format:@"%s - Download \"%@\" should be found in queue.", __PRETTY_FUNCTION__, download.description];
                return;
            }

            if (filePath) {
                download.state = TCDownloadStateCompleted;

                if (weakSelf.downloadStateDidChange) {
                    weakSelf.downloadStateDidChange(downloadIndex);
                }
            } else {
                download.state = TCDownloadStateFailed;

                if (weakSelf.downloadStateDidChange) {
                    weakSelf.downloadStateDidChange(downloadIndex);
                }
            }
        }];

        // Start the download task.
        download.task = downloadTask;
        [download.task resume];
        download.state = TCDownloadStateRunning;
    }
}

#pragma mark - Setting Download Callbacks

- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block
{
    self.downloadStateDidChange = block;
}

#pragma mark - Private Mutable Download Queue

- (NSMutableArray *)mutableDownloads
{
    if (!_mutableDownloads) {
        _mutableDownloads = [[NSMutableArray alloc] init];
    }
    return _mutableDownloads;
}

@end
