//
//  TCDownloadQueue.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;

typedef void(^TCDownloadQueueDownloadStateDidChangeBlock)(NSUInteger index);

//typedef void(^TCDownloadQueueDownloadProgressDidChangeBlock)(NSUInteger index);
//typedef void(^TCDownloadQueueDownloadDidFinishBlock)(NSUInteger index);
//typedef void(^TCDownloadQueueDownloadDidFailBlock)(NSUInteger index, NSError *error);

/**
 * \c TCDownloadQueue class coordinates a set of downloads.
 */
@interface TCDownloadQueue : NSObject

/**
 * The number of downloads currently in progress.
 */
@property (nonatomic, assign, readonly) NSUInteger downloadCount;

- (id)initWithSessionManager:(AFURLSessionManager *)sessionManager;

/**
 * Returns the download at given index.
 */
- (TCDownload *)downloadAtIndex:(NSUInteger)index;

/**
 * Adds the given download to the end of the queue.
 */
- (void)addDownload:(TCDownload *)download;

/**
 * Sets a block to be called when a download's state or progress has changed.
 *
 * @param block The block has no return value and takes a single argument - 
 *              the index of the download.
 */
- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block;

///**
// * Sets the block to be called when a download has updated its progress.
// */
//- (void)setDownloadProgressDidChangeBlock:(TCDownloadQueueDownloadProgressDidChangeBlock)block;
//
//- (void)setDownloadDidFinishBlock:(TCDownloadQueueDownloadDidFinishBlock)block;
//
//- (void)setDownloadDidFailBlock:(TCDownloadQueueDownloadDidFailBlock)block;

@end
