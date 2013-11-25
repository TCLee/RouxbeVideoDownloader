//
//  TCDownloadQueue.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;

/**
 * The signature of the block object that will be called when a download's 
 * state or progress has changed.
 *
 * @param index The index of the download whose state or progress has changed.
 */
typedef void(^TCDownloadQueueDownloadStateDidChangeBlock)(NSUInteger index);

/**
 * \c TCDownloadQueue class coordinates a set of download operations.
 * Each download is represented by a \c TCDownload object.
 *
 * @see TCDownload
 */
@interface TCDownloadQueue : NSObject

/**
 * The number of downloads currently in progress.
 */
@property (nonatomic, assign, readonly) NSUInteger downloadCount;

/**
 * Initializes a new download queue with the default session manager.
 *
 * @return A \c TCDownloadQueue object initialized with the default session manager.
 */
- (id)init;

/**
 * Initializes a new download queue with the given session manager that will
 * manage the session that coordinates all download tasks.
 *
 * @param sessionManager The \c AFURLSessionManager object or \c nil to 
 *                       use the default session manager.
 *
 * @return A \c TCDownloadQueue object initialized with the given session manager.
 */
- (id)initWithSessionManager:(AFURLSessionManager *)sessionManager;

/**
 * Returns the download at given index.
 */
- (TCDownload *)downloadAtIndex:(NSUInteger)index;

/**
 * Adds the array of downloads to the end of the queue.
 *
 * @param downloads An array of \c TCDownload objects.
 */
- (void)addDownloads:(NSArray *)downloads;

/**
 * Sets a block to be called when a download's state or progress has changed.
 *
 * @param block The block has no return value and takes a single argument - 
 *              the index of the download.
 */
- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block;

@end
