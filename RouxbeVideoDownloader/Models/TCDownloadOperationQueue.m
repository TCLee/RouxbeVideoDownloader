//
//  TCDownloadOperationQueue.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadOperationQueue.h"
#import "TCDownloadOperation.h"

static void * TCDownloadOperationStateChangedContext = &TCDownloadOperationStateChangedContext;

static NSString * const TCDownloadOperationReadyKeyPath = @"isReady";
static NSString * const TCDownloadOperationExecutingKeyPath = @"isExecuting";
static NSString * const TCDownloadOperationFinishedKeyPath = @"isFinished";
static NSString * const TCDownloadOperationPausedKeyPath = @"isPaused";
static NSString * const TCDownloadOperationCancelledKeyPath = @"isCancelled";

@interface TCDownloadOperationQueue ()

@property (readwrite, nonatomic, strong) NSMutableOrderedSet *allOperations;
@property (readwrite, nonatomic, strong) NSMutableOrderedSet *runningOperations;
@property (readwrite, nonatomic, strong) NSMutableOrderedSet *waitingOperations;

@end

@implementation TCDownloadOperationQueue

- (id)initWithMaxConcurrentDownloadCount:(NSUInteger)maxConcurrentDownloadCount
{
    self = [super init];
    if (self) {
        _maxConcurrentDownloadCount = maxConcurrentDownloadCount;

        _allOperations = [[NSMutableOrderedSet alloc] init];
        _runningOperations = [[NSMutableOrderedSet alloc] init];
        _waitingOperations = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

#pragma mark - Managing Download Operations in the Queue

- (NSUInteger)downloadOperationCount
{
    return self.allOperations.count;
}

- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index
{
    return (TCDownloadOperation *)self.allOperations[index];
}

- (void)addDownloadOperations:(NSArray *)operations
{
    for (TCDownloadOperation *operation in operations) {
        [self addDownloadOperation:operation];
    }
}

- (void)addDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSParameterAssert(downloadOperation);
    NSAssert(downloadOperation.isReady,
             @"Should only add a download operation that is in Ready state.");
    NSAssert(NSNotFound == [self.allOperations indexOfObject:downloadOperation],
             @"Attempted to add duplicate download operation to queue.");

    [self.allOperations addObject:downloadOperation];

    [self registerAsObserverForDownloadOperation:downloadOperation];

    [self startOrSuspendDownloadOperation:downloadOperation];
}

#pragma mark - Controlling Download Operation State

- (void)pauseDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *downloadOperation = self.allOperations[index];

    NSAssert(downloadOperation.isReady || downloadOperation.isExecuting,
             @"Should only be called when download operation is in Ready or Executing state.");

    if (downloadOperation.isReady || downloadOperation.isExecuting) {
        // Get the operation's executing state before it is paused.
        BOOL downloadOperationWasRunning = downloadOperation.isExecuting;

        // Paused download operations are not added to the waiting list.
        // This is because only a user can pause a download and we should
        // not automatically start a download the user wanted to pause.
        [downloadOperation pause];

        // Remove download operation from running list, if it was running
        // before it was paused.
        if (downloadOperationWasRunning) {
            [self.runningOperations removeObject:downloadOperation];
        }

        // Attempt to start the next operation in the waiting list,
        // since we now have an available slot.
        [self startNextDownloadOperationInWaitingList];
    }
}

- (void)resumeDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *downloadOperation = self.allOperations[index];

    NSAssert(downloadOperation.isPaused,
             @"Should only be called when download operation is in Paused state.");

    if (downloadOperation.isPaused) {
        [self startOrSuspendDownloadOperation:downloadOperation];
    }
}

- (void)retryFailedDownloadOperationAtIndex:(NSUInteger)index
{
    TCDownloadOperation *operation = self.allOperations[index];

    NSAssert(operation.isFinished && operation.error,
             @"Should only be called when download operation has failed.");

    if (operation.isFinished && operation.error) {
        // Make a copy of the failed operation so that its state is Ready.
        // The original failed operation's state is Finished and we can't do
        // anything with it.
        TCDownloadOperation *operationCopy = [operation copy];

        // Replace the failed operation with the new copy.
        self.allOperations[index] = operationCopy;

        // Start the new copy of the operation.
        [self startOrSuspendDownloadOperation:operationCopy];
    }
}

#pragma mark - Private Queue Management Methods

/**
 * Starts the given download operation if there is an available slot.
 * Otherwise, it suspends the download operation by adding it to the waiting 
 * list. The download operation will be executed later when there is an 
 * available slot.
 */
- (void)startOrSuspendDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSAssert(downloadOperation.isReady || downloadOperation.isPaused,
             @"Should only start a download operation in Ready or Paused state.");

    if (self.runningOperations.count <= self.maxConcurrentDownloadCount) {
        [self startDownloadOperation:downloadOperation];
    } else {
        [self suspendDownloadOperation:downloadOperation];
    }
}

/**
 * Starts or resumes the given download operation. It also adds the
 * download operation to the running list and removes it from the 
 * waiting list (if found).
 */
- (void)startDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSAssert(downloadOperation.isReady || downloadOperation.isPaused,
             @"Should only start a download operation in Ready or Paused state.");

    if (downloadOperation.isReady) {
        [downloadOperation start];
    } else if (downloadOperation.isPaused) {
        [downloadOperation resume];
    }

    [self.runningOperations addObject:downloadOperation];
    [self.waitingOperations removeObject:downloadOperation];
}

/**
 * Suspends the given download operation by adding operation to the waiting 
 * list and removing operation from the running list (if found).
 */
- (void)suspendDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSAssert(!downloadOperation.isFinished,
             @"Cannot suspend a finished download operation.");

    [self.runningOperations removeObject:downloadOperation];
    [self.waitingOperations addObject:downloadOperation];
}

/**
 * Marks the given download operation as finished and removes it from 
 * both the running and waiting list. 
 *
 * Note that the download operation is still in the queue. It is just removed
 * from the running and waiting list.
 */
- (void)downloadOperationDidFinish:(TCDownloadOperation *)downloadOperation
{
    NSAssert(downloadOperation.isFinished,
             @"Should only mark a download operation as finished, if isFinished == YES.");

    // Remove ourselves as observer, since the operation has finished
    // and there is nothing to observe anymore.
    [self unregisterAsObserverForDownloadOperation:downloadOperation];

    [self.runningOperations removeObject:downloadOperation];
    [self.waitingOperations removeObject:downloadOperation];
}

/**
 * Starts the next available download operation in the waiting list.
 * If there are no operations in the waiting list, then it does nothing.
 */
- (void)startNextDownloadOperationInWaitingList
{
    if (self.waitingOperations.count > 0) {
        [self startOrSuspendDownloadOperation:self.waitingOperations.firstObject];
    }
}

#pragma mark - Key-Value Observing (KVO)

+ (NSArray *)allOperationStateKeyPaths
{
    static NSArray *allStateKeyPaths = nil;
    if (!allStateKeyPaths) {
        allStateKeyPaths = @[TCDownloadOperationReadyKeyPath,
                             TCDownloadOperationExecutingKeyPath,
                             TCDownloadOperationFinishedKeyPath,
                             TCDownloadOperationPausedKeyPath];
    }
    return allStateKeyPaths;
}

- (void)registerAsObserverForDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSArray *keyPaths = [[self class] allOperationStateKeyPaths];
    for (NSString *keyPath in keyPaths) {
        [downloadOperation addObserver:self
                            forKeyPath:keyPath
                               options:NSKeyValueObservingOptionNew
                               context:TCDownloadOperationStateChangedContext];
    }
}

- (void)unregisterAsObserverForDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    NSArray *keyPaths = [[self class] allOperationStateKeyPaths];
    for (NSString *keyPath in keyPaths) {
        [downloadOperation removeObserver:self
                               forKeyPath:keyPath
                                  context:TCDownloadOperationStateChangedContext];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == TCDownloadOperationStateChangedContext &&
        [keyPath isEqualToString:TCDownloadOperationFinishedKeyPath]) {

        TCDownloadOperation *downloadOperation = (TCDownloadOperation *)object;
        BOOL operationIsFinished = [change[NSKeyValueChangeNewKey] boolValue];

        if (operationIsFinished) {
            [self downloadOperationDidFinish:downloadOperation];

            // When download operation has finished, this will free up an
            // available slot for the next download operation in the waiting list.
            [self startNextDownloadOperationInWaitingList];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
