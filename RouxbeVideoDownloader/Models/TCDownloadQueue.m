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

@interface TCDownloadQueue ()

/**
 * The session manager that manages the session for all download tasks.
 */
@property (nonatomic, strong) AFURLSessionManager *sessionManager;

/**
 * The mutable download queue for internal use only.
 */
@property (nonatomic, strong) NSMutableArray *mutableDownloads;

//@property (nonatomic, strong) NSMutableArray *mutableRunningTasks;

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

- (id)init
{
    return [self initWithSessionManager:nil];
}

- (id)initWithSessionManager:(AFURLSessionManager *)aSessionManager
{
    self = [super init];
    if (self) {
        // If no session manager is provided, we'll create our own session
        // manager using the default configuration.
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

    __weak typeof(self)weakSelf = self;

    for (TCDownload *download in downloads) {
        // Create a download task for each download object.
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:download.sourceURL];
        download.task = [self.sessionManager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return download.destinationURL;
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            // Remove completed task from dictionary.
            [weakSelf.downloadsKeyedByTaskIdentifier removeObjectForKey:@(download.task.taskIdentifier)];

            if (filePath) {
                download.state = TCDownloadStateCompleted;
                download.error = error;
            } else {
                download.state = TCDownloadStateFailed;
                download.error = nil;
            }

            if (weakSelf.downloadStateDidChange) {
                weakSelf.downloadStateDidChange([weakSelf.mutableDownloads indexOfObjectIdenticalTo:download]);
            }
        }];

        // Associate the task with the download.
        weakSelf.downloadsKeyedByTaskIdentifier[@(download.task.taskIdentifier)] = download;

        // Start the download task.
//        [download resume];
    }
}

#pragma mark - Setting Download Callbacks

- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block
{
    self.downloadStateDidChange = block;
}

#pragma mark - Downloads Keyed By Task Identifier Dictionary

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
