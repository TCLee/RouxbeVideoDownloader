//
//  TCDownloadOperationQueue.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadOperation;

@interface TCDownloadOperationQueue : NSObject

- (id)initWithMaxConcurrentDownloadCount:(NSUInteger)maxConcurrentDownloadCount;

- (void)addDownloadOperation:(TCDownloadOperation *)operation;

- (void)addDownloadOperations:(NSArray *)operations;

- (NSUInteger)downloadOperationCount;

- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index;

- (void)pauseDownloadOperationAtIndex:(NSUInteger)index;

- (void)resumeDownloadOperationAtIndex:(NSUInteger)index;

- (void)retryFailedDownloadOperationAtIndex:(NSUInteger)index;

@end
