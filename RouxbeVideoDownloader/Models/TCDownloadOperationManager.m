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
 *
 * @see TCDownloadOperationManager::operationQueue
 */
@property (nonatomic, strong) NSMutableArray *mutableDownloadOperations;

/**
 * The operation queue that coordinates the set of download operations.
 *
 * @see TCDownloadOperationManager::mutableDownloadOperations
 */
@property (nonatomic, strong) NSOperationQueue *operationQueue;

/**
 * The block object to execute when a download operation's progress or state has changed.
 */
@property (readwrite, nonatomic, copy) TCDownloadOperationManagerDownloadOperationDidChangeBlock downloadOperationDidChange;

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
        //TODO: Uncomment after testing!
//        _operationQueue.maxConcurrentOperationCount = _configuration.maxConcurrentDownloadCount;
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark - Add Download Operations

- (void)addDownloadOperationsWithURL:(NSURL *)aURL
                       completeBlock:(TCDownloadOperationManagerAddDownloadOperationsCompleteBlock)completeBlock
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
                if (operation) {
                    [mutableOperations addObject:operation];
                }
            }

            // Add the download operations to the operation queue.
            [strongSelf.mutableDownloadOperations addObjectsFromArray:mutableOperations];
            [strongSelf.operationQueue addOperations:mutableOperations waitUntilFinished:NO];
        }

        if (completeBlock) {
            completeBlock(mutableOperations, error);
        }
    }];
}

/**
 * Creates and returns a download operation for the given video.
 */
- (TCDownloadOperation *)downloadOperationWithVideo:(TCVideo *)video
{
    NSURL *destinationURL = [self.configuration.downloadsDirectoryURL URLByAppendingPathComponent:video.destinationPathComponent];
    TCDownloadOperation *downloadOperation = [[TCDownloadOperation alloc] initWithRequest:[NSURLRequest requestWithURL:video.sourceURL]
                                                                   destinationURL:destinationURL
                                                                            title:video.destinationPathComponent];

    __weak typeof(self) weakSelf = self;

    [downloadOperation setDownloadOperationDidChange:^(TCDownloadOperation *operation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSUInteger index = [strongSelf.mutableDownloadOperations indexOfObjectIdenticalTo:operation];
        if (NSNotFound == index) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"Download operation should exist because it is never removed."];
        }

        if (strongSelf.downloadOperationDidChange) {
            strongSelf.downloadOperationDidChange(index);
        }
    }];

    return downloadOperation;
}

#pragma mark - Download Operation Queue

- (NSUInteger)downloadOperationCount
{
    return self.mutableDownloadOperations.count;
}

- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index
{
    return (TCDownloadOperation *)self.mutableDownloadOperations[index];
}

#pragma mark - Resume/Cancel Download

- (void)resumeDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *downloadOperation = self.mutableDownloadOperations[index];

    // Only resume download operations that have failed or cancelled.
    // A cancelled download operation is treated as an error.
    if (downloadOperation.isFinished && downloadOperation.error) {
        
        // Create a copy of the failed download operation.
        // The original failed download operation cannot be added back
        // to the operation queue.
        TCDownloadOperation *operationCopy = [downloadOperation copy];

        // Add the copy to the operation queue. The original download
        // operation has been removed from the operation queue when it failed.
        [self.operationQueue addOperation:operationCopy];

        // Replace the original failed download operation with the copy.
        self.mutableDownloadOperations[index] = operationCopy;
    }
}

- (void)cancelDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *downloadOperation = self.mutableDownloadOperations[index];
    [downloadOperation cancel];
}

#pragma mark - Set Download Operation Callback

- (void)setDownloadOperationDidChangeBlock:(TCDownloadOperationManagerDownloadOperationDidChangeBlock)block
{
    self.downloadOperationDidChange = block;
}

@end
