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
 * state has changed.
 *
 * @param index The index of the download.
 */
typedef void(^TCDownloadQueueDownloadStateDidChangeBlock)(NSUInteger index);

/**
 * \c TCDownloadQueue class coordinates a set of download operations.
 */
@interface TCDownloadQueue : NSObject

/**
 * The number of downloads currently in progress.
 */
@property (nonatomic, assign, readonly) NSUInteger downloadCount;

/**
 * <#Description#>
 *
 * @param sessionManager <#sessionManager description#>
 *
 * @return <#return value description#>
 */
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
