//
//  TCDownloadQueue.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadQueue.h"
#import "TCDownload.h"
#import "TCDownload+TCDownloadQueueAdditions.h"

typedef NSURL *(^AFURLSessionDownloadTaskDestinationBlock)(NSURL *targetPath, NSURLResponse *response);
typedef void(^AFURLSessionDownloadTaskCompletionHandler)(NSURLResponse *response, NSURL *fileURL, NSError *error);

@interface TCDownloadQueue ()

/**
 * The session manager that manages the session for all download tasks.
 */
@property (nonatomic, strong) AFURLSessionManager *sessionManager;

/**
 * The mutable download queue for internal use only.
 */
@property (nonatomic, strong) NSMutableArray *mutableDownloads;

/**
 * The block object to execute when a download's state or progress has changed.
 */
@property (nonatomic, copy) TCDownloadQueueDownloadStateDidChangeBlock downloadStateDidChange;

/**
 * The dictionary to associate a download with its task. The key is the task's 
 * identifier and the value is the download object.
 */
@property (nonatomic, strong) NSMutableDictionary *downloadsKeyedByTaskIdentifier;

@end

@implementation TCDownloadQueue

#pragma mark - Initialize

- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration
{
    self = [super init];

    if (self) {
        // Use the default session configuration, if one was not provided.
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }

        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        [self configureCallbacksForSessionManager:_sessionManager];
    }

    return self;
}

- (void)configureCallbacksForSessionManager:(AFURLSessionManager *)sessionManager
{
    __weak typeof(self)weakSelf = self;

    // This block will be called on the AFURLSessionManager's operation queue
    // and NOT the main queue. So, it's important for us to switch to the main
    // queue before updating the download's progress and making a callback.
    [sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSDate *now = [NSDate date];

        dispatch_async(dispatch_get_main_queue(), ^{
            TCDownload *download = weakSelf.downloadsKeyedByTaskIdentifier[@(downloadTask.taskIdentifier)];

            [download setProgressWithBytesWritten:bytesWritten
                                totalBytesWritten:totalBytesWritten
                        totalBytesExpectedToWrite:totalBytesExpectedToWrite
                                        timestamp:now];

            if (weakSelf.downloadStateDidChange) {
                weakSelf.downloadStateDidChange([weakSelf.mutableDownloads indexOfObjectIdenticalTo:download]);
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

    for (TCDownload *download in downloads) {
        // Create a new session download task for the download.
        download.task = [self downloadTaskWithDownload:download];

        // Associate the task's unique identifier with the download.
        // We will need to retrieve the download object using this task identifier later.
        self.downloadsKeyedByTaskIdentifier[@(download.task.taskIdentifier)] = download;

        // Download tasks are suspended until we call resume to start.
//        [download resume];
    }
}

#pragma mark - Create Download Task

/**
 * Creates a download task that will perform the actual downloading.
 *
 * @param download The \c TCDownload object that the download task will be created for.
 *
 * @return The new session download task.
 */
- (NSURLSessionDownloadTask *)downloadTaskWithDownload:(TCDownload *)download
{
    __weak typeof(self)weakSelf = self;
    TCDownload *__weak weakDownload = download;
    NSURLSessionDownloadTask *__block downloadTask = nil;

    // Block that will be called to determine the destination URL of the
    // download.
    AFURLSessionDownloadTaskDestinationBlock destinationBlock = ^(NSURL *targetPath, NSURLResponse *response) {
        return weakDownload.destinationURL;
    };

    // Block that will be called when download task has completed or failed
    // with an error.
    AFURLSessionDownloadTaskCompletionHandler completionHandler = ^(NSURLResponse *response, NSURL *fileURL, NSError *error) {
        // Remove completed task from dictionary.
        [weakSelf.downloadsKeyedByTaskIdentifier removeObjectForKey:@(weakDownload.task.taskIdentifier)];

        // Set download state to be completed (or failed with an error).
        [weakDownload setCompletedWithFileURL:fileURL error:error];

        if (weakSelf.downloadStateDidChange) {
            weakSelf.downloadStateDidChange([weakSelf.mutableDownloads indexOfObjectIdenticalTo:download]);
        }
    };

    // If download has resume data, we will create a download task to resume
    // the download from where it was failed or cancelled.
    // Otherwise, we will create a download task for a new download.
    if (download.resumeData) {
        downloadTask = [self.sessionManager downloadTaskWithResumeData:download.resumeData
                                                              progress:nil
                                                           destination:destinationBlock
                                                     completionHandler:completionHandler];
    } else {
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:download.sourceURL];
        downloadTask = [self.sessionManager downloadTaskWithRequest:request
                                                           progress:nil
                                                        destination:destinationBlock
                                                  completionHandler:completionHandler];
    }
    return downloadTask;
}

#pragma mark - Resume and Cancel Downloads

- (void)resumeDownload:(TCDownload *)download
{
    // Re-create and resume the download task for a failed or
    // cancelled download.
    if (TCDownloadStateCancelled == download.state ||
        TCDownloadStateFailed == download.state) {

        download.task = [self downloadTaskWithDownload:download];
        self.downloadsKeyedByTaskIdentifier[@(download.task.taskIdentifier)] = download;
        [download resume];
    }

    // Does nothing, if download has not been cancelled or failed.
}

- (void)cancelDownload:(TCDownload *)download
{
    if (TCDownloadStateRunning == download.state) {
        [download cancel];
    }

    // Does nothing, if download is not running.
}

- (void)resumeDownloadAtIndex:(NSUInteger)index
{
    [self resumeDownload:[self downloadAtIndex:index]];
}

- (void)cancelDownloadAtIndex:(NSUInteger)index
{
    [self cancelDownload:[self downloadAtIndex:index]];
}

#pragma mark - Setting Download Callbacks

- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block
{
    self.downloadStateDidChange = block;
}

#pragma mark - Download Tasks Dictionary

- (NSMutableDictionary *)downloadsKeyedByTaskIdentifier
{
    if (!_downloadsKeyedByTaskIdentifier) {
        _downloadsKeyedByTaskIdentifier = [[NSMutableDictionary alloc] init];
    }
    return _downloadsKeyedByTaskIdentifier;
}

#pragma mark - Mutable Download Queue

- (NSMutableArray *)mutableDownloads
{
    if (!_mutableDownloads) {
        _mutableDownloads = [[NSMutableArray alloc] init];
    }
    return _mutableDownloads;
}

@end
