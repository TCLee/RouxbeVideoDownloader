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

/**
 * The context object used for Key-Value Observing (KVO).
 */
static void * TCDownloadConfigurationChangedContext = &TCDownloadConfigurationChangedContext;

/**
 * The key path of \c TCDownloadConfiguration property to observe.
 */
static NSString * const TCMaxConcurrentDownloadCountKeyPath = @"maxConcurrentDownloadCount";

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
@property (nonatomic, strong) NSMutableArray *allDownloadOperations;

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
        _configuration = theConfiguration;
        [_configuration addObserver:self
                         forKeyPath:TCMaxConcurrentDownloadCountKeyPath
                            options:NSKeyValueObservingOptionNew
                            context:TCDownloadConfigurationChangedContext];

        _allDownloadOperations = [[NSMutableArray alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = _configuration.maxConcurrentDownloadCount;
    }
    return self;
}

- (void)dealloc
{
    [self.configuration removeObserver:self
                            forKeyPath:TCMaxConcurrentDownloadCountKeyPath
                               context:TCDownloadConfigurationChangedContext];
}

#pragma mark - Add/Remove Download Operations

- (AFHTTPRequestOperation *)addDownloadOperationsWithURL:(NSURL *)aURL
                                           completeBlock:(TCDownloadOperationManagerAddDownloadOperationsCompleteBlock)completeBlock
{
    __weak typeof(self) weakSelf = self;

    return [TCVideo getVideosFromURL:aURL completeBlock:^(NSArray *videos, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSMutableArray *mutableOperations = nil;
        if (videos) {
            // For each video found, create a download operation for it.
            mutableOperations = [[NSMutableArray alloc] initWithCapacity:videos.count];
            for (TCVideo *video in videos) {
                TCDownloadOperation *operation = [strongSelf downloadOperationWithVideo:video];
                if (!operation) { continue; } // Failed to create download operation.

                [mutableOperations addObject:operation];
            }

            // Add the download operations to the operation queue.
            [strongSelf addDownloadOperations:mutableOperations];
        }

        if (completeBlock) {
            completeBlock(mutableOperations, error);
        }
    }];
}

/**
 * Adds an array of download operations to the download queue.
 */
- (void)addDownloadOperations:(NSArray *)operations
{
    [self.allDownloadOperations addObjectsFromArray:operations];
    [self.operationQueue addOperations:operations waitUntilFinished:NO];
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

    void(^callback)(TCDownloadOperation *) = ^(TCDownloadOperation *operation) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        NSUInteger index = [strongSelf.allDownloadOperations indexOfObject:operation];

        // If download operation has already been removed from the queue, then
        // there's is no point in making the callback.
        if (NSNotFound != index && strongSelf.downloadOperationDidChange) {
            strongSelf.downloadOperationDidChange(index);
        }
    };

    // We only care whether the download operation has changed.
    [downloadOperation setDidStartBlock:callback];
    [downloadOperation setDidUpdateProgressBlock:callback];
    [downloadOperation setDidFinishBlock:callback];
    [downloadOperation setDidFailBlock:callback];

    return downloadOperation;
}

- (void)removeFinishedDownloadOperations
{
    // Only remove download operations that have finished successfully.
    [self.allDownloadOperations filterUsingPredicate:
     [NSPredicate predicateWithFormat:@"!(isFinished == YES && error == nil)"]];

    // We don't have to remove finished operations from the operation
    // queue, since it's performed automatically.
}

#pragma mark - Download Operation Queue

- (NSUInteger)downloadOperationCount
{
    return self.allDownloadOperations.count;
}

- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index
{
    return (TCDownloadOperation *)self.allDownloadOperations[index];
}

#pragma mark - Resume/Cancel Download

- (void)resumeDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *operation = self.allDownloadOperations[index];

    // Only resume download operations that have failed or cancelled.
    // A cancelled download operation is treated as an error.
    if (operation.isFinished && operation.error) {
        
        // Create a copy of the failed download operation.
        // The original failed download operation cannot be added back
        // to the operation queue.
        TCDownloadOperation *operationCopy = [operation copy];

        // Add the copy to the operation queue. The original download
        // operation has been removed from the operation queue when it failed.
        [self.operationQueue addOperation:operationCopy];

        // Replace the original failed download operation with the copy.
        self.allDownloadOperations[index] = operationCopy;
    }
}

- (void)cancelDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *operation = self.allDownloadOperations[index];

    // If we attempt to cancel a download operation that is Ready (but not Executing yet),
    // AFNetworking will move the operation from Ready -> Finished state directly.
    // NSOperationQueue only allows operations to move from Ready -> Executing -> Finished state.
    if (operation.isExecuting) {
        [operation cancel];
    }
}

#pragma mark - Set Download Operation Callback

- (void)setDownloadOperationDidChangeBlock:(TCDownloadOperationManagerDownloadOperationDidChangeBlock)block
{
    self.downloadOperationDidChange = block;
}

#pragma mark - Key-Value Observing (KVO)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == TCDownloadConfigurationChangedContext &&
        [keyPath isEqualToString:TCMaxConcurrentDownloadCountKeyPath]) {

        // Update the NSOperationQueue's maxConcurrentOperationCount property
        // when TCDownloadConfiguration's corresponding property has changed.
        TCDownloadConfiguration *theConfiguration = (TCDownloadConfiguration *)object;
        self.operationQueue.maxConcurrentOperationCount = theConfiguration.maxConcurrentDownloadCount;
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

@end
