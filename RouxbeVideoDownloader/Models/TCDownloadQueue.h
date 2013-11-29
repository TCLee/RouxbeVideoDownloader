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
 * Initializes a new download queue with the given configuration used to 
 * create the session.
 *
 * @param configuration The session configuration for all download tasks.
 *
 * @return A \c TCDownloadQueue object that uses a session with the given 
 *         configuration.
 */
- (instancetype)initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration;

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
 * Resumes the given download.
 *
 * If the download is currently running or has completed, this method
 * does nothing.
 */
- (void)resumeDownload:(TCDownload *)download;

/**
 * Resumes a failed or cancelled download at given index.
 *
 * If download is currently running or has completed, this method 
 * does nothing.
 */
- (void)resumeDownloadAtIndex:(NSUInteger)index;

/**
 * Cancels the given download.
 *
 * If download is not running, this method does nothing.
 */
- (void)cancelDownload:(TCDownload *)download;

/**
 * Cancels the download at given index.
 *
 * If download is not running, this method does nothing.
 */
- (void)cancelDownloadAtIndex:(NSUInteger)index;

/**
 * Sets a block to be called when a download's state or progress has changed.
 *
 * @param block The block has no return value and takes a single argument - 
 *              the index of the download.
 */
- (void)setDownloadStateDidChangeBlock:(TCDownloadQueueDownloadStateDidChangeBlock)block;

@end
