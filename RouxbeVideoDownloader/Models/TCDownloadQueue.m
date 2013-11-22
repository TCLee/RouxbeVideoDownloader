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

@property (nonatomic, strong) AFURLSessionManager *sessionManager;
@property (nonatomic, strong, readonly) NSMutableArray *mutableDownloads;

@property (nonatomic, copy) TCDownloadQueueDownloadDidFinishBlock downloadDidFinish;
@property (nonatomic, copy) TCDownloadQueueDownloadDidFailBlock downloadDidFail;
@property (nonatomic, copy) TCDownloadQueueDownloadProgressDidChangeBlock downloadProgressDidChange;

@end

@implementation TCDownloadQueue

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
        // session manager.
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

            if (weakSelf.downloadProgressDidChange) {
                weakSelf.downloadProgressDidChange(downloadIndex);
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

- (void)addDownload:(TCDownload *)download
{
    NSParameterAssert(download);

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:download.sourceURL];

    // Create the download task that will perform the actual download.
    NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return download.destinationURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSUInteger indexToRemove = [self.mutableDownloads indexOfObject:download];
        if (NSNotFound == indexToRemove) { return; }

        [self.mutableDownloads removeObjectAtIndex:indexToRemove];

        if (error) {
            if (self.downloadDidFail) {
                self.downloadDidFail(indexToRemove, error);
            }
        } else {
            if (self.downloadDidFinish) {
                self.downloadDidFinish(indexToRemove);
            }
        }
    }];

    download.task = downloadTask;
    [download.task resume];
}

#pragma mark - Setting Download Callbacks

- (void)setDownloadDidFinishBlock:(TCDownloadQueueDownloadDidFinishBlock)block
{
    self.downloadDidFinish = block;
}

- (void)setDownloadDidFailBlock:(TCDownloadQueueDownloadDidFailBlock)block
{
    self.downloadDidFail = block;
}

- (void)setDownloadDidChangeProgressBlock:(TCDownloadQueueDownloadProgressDidChangeBlock)block
{
    self.downloadProgressDidChange = block;
}

@end
