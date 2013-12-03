//
//  TCDownloadOperationManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/30/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadOperationManager.h"
#import "TCDownloadOperation.h"
#import "TCDownloadConfiguration.h"

#import "TCVideo.h"

@interface TCDownloadOperationManager ()

/**
 * The mutable array of all download operations that have been added to 
 * the operation queue.
 *
 * Unlike the operation queue, download operations that have finished are
 * not removed.
 */
@property (nonatomic, strong) NSMutableArray *mutableDownloadOperations;

/**
 * The operation queue that coordinates the set of download operations.
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/**
 * The block object to execute when a download operation's progress has changed.
 */
@property (nonatomic, copy) TCDownloadOperationManagerDownloadProgressBlock downloadOperationProgress;

@end

@implementation TCDownloadOperationManager

#pragma mark - Initialize

- (instancetype)initWithConfiguration:(TCDownloadConfiguration *)theConfiguration
{
    NSParameterAssert(theConfiguration);

    self = [super init];
    if (self) {
        _configuration = [theConfiguration copy];

        _mutableDownloadOperations = [[NSMutableArray alloc] init];

        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = _configuration.maxConcurrentDownloadCount;
    }
    return self;
}

#pragma mark - Add Download Operations

- (void)addDownloadOperationsWithURL:(NSURL *)aURL
                       completeBlock:(TCDownloadOperationManagerAddDownloadsCompleteBlock)completeBlock
{
    __weak typeof(self) weakSelf = self;

    [TCVideo findVideosFromURL:aURL completeBlock:^(NSArray *videos, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSMutableArray *mutableOperations = nil;
        if (videos) {
            // For each video found, create a download operation for it.
            mutableOperations = [[NSMutableArray alloc] initWithCapacity:videos.count];
            for (TCVideo *video in videos) {
                TCDownloadOperation *operation = [strongSelf downloadOperationWithVideo:video];
                [mutableOperations addObject:operation];
            }

            // Add the download operations to the operation queue.
            [strongSelf.operationQueue addOperations:mutableOperations waitUntilFinished:NO];
            [strongSelf.mutableDownloadOperations addObjectsFromArray:mutableOperations];
        }

        if (completeBlock) {
            completeBlock(mutableOperations, error);
        }
    }];
}

/**
 * Creates and returns a download operation from the given video.
 */
- (TCDownloadOperation *)downloadOperationWithVideo:(TCVideo *)video
{
    NSURL *destinationURL = [self.configuration.downloadsDirectoryURL URLByAppendingPathComponent:video.destinationPathComponent];
    TCDownloadOperation *operation = [[TCDownloadOperation alloc] initWithSourceURL:video.sourceURL
                                                                     destinationURL:destinationURL
                                                                              title:video.destinationPathComponent];

    __weak typeof(self) weakSelf = self;

    [operation setProgressChangedBlock:^(TCDownloadOperation *operation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSUInteger index = [strongSelf.mutableDownloadOperations indexOfObjectIdenticalTo:operation];
        if (NSNotFound == index) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Download operation should exist because it is never removed."];
        }

        if (strongSelf.downloadOperationProgress) {
            strongSelf.downloadOperationProgress(index);
        }
    }];

    return operation;
}

#pragma mark - Getting Download Operation Info

- (NSUInteger)downloadOperationCount
{
    return self.mutableDownloadOperations.count;
}

- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index
{
    return (TCDownloadOperation *)self.mutableDownloadOperations[index];
}

#pragma mark - Resume Failed Download

- (void)resumeFailedDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *downloadOperation = self.mutableDownloadOperations[index];

    if (downloadOperation.isFinished && downloadOperation.error) {
        // Create a copy of the failed download operation.
        // The original failed download operation cannot be added back
        // to the operation queue.
        TCDownloadOperation *downloadOperationCopy = [downloadOperation copy];

        // Add the copy to the operation queue. The original failed download
        // operation has been removed from the operation queue.
        [self.operationQueue addOperation:downloadOperationCopy];

        // Replace the original failed download operation with the copy.
        self.mutableDownloadOperations[index] = downloadOperationCopy;
    } else {
        [NSException raise:NSInvalidArgumentException
                    format:@"This method should only be called on failed download operations."];
    }
}

#pragma mark - Set Download Progress Callbacks

- (void)setDownloadOperationProgressBlock:(TCDownloadOperationManagerDownloadProgressBlock)block
{
    self.downloadOperationProgress = block;
}

@end
