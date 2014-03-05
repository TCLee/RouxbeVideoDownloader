//
//  TCDownloadOperationManager.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/30/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadConfiguration;
@class TCDownloadOperation;

/**
 * The prototype of the block that will be called when the \c TCDownloadOperationManager
 * has added the download operations to the operation queue.
 *
 * @param newDownloadOperations The array of new \c TCDownloadOperation objects added to the operation queue or \c nil on error.
 * @param error                 The \c NSError object describing the error or \c nil on success.
 */
typedef void(^TCDownloadOperationManagerAddDownloadOperationsCompleteBlock)(NSArray *newDownloadOperations, NSError *error);

/**
 * The prototype of the block that will be called when a download 
 * operation's state or progress has changed.
 *
 * @param index The index of the download operation in the \c TCDownloadOperationManager operation queue.
 */
typedef void(^TCDownloadOperationManagerDownloadOperationDidChangeBlock)(NSUInteger index);

/**
 * \c TCDownloadOperationManager manages an operation queue that coordinates
 * and schedules a set of \c TCDownloadOperation objects.
 */
@interface TCDownloadOperationManager : NSObject

/**
 * The configuration object used to configure the behavior of this 
 * \c TCDownloadOperationManager.
 */
@property (readonly, nonatomic, copy) TCDownloadConfiguration *configuration;

/**
 * Initializes a \c TCDownloadOperationManager with the given configuration.
 */
- (instancetype)initWithConfiguration:(TCDownloadConfiguration *)configuration;

/**
 * The number of download operations that is managed by the
 * \c TCDownloadOperationManager operation queue.
 */
- (NSUInteger)downloadOperationCount;

/**
 * Returns the download operation at the given index.
 */
- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index;

/**
 * Adds one or more download operations from the given URL to the 
 * operation queue. The completion block will be called when the 
 * download operations have been added to the operation queue
 * (or an error occured).
 *
 * This method will search the given URL for video resources. 
 * For each video that it finds, it will create a download operation 
 * for the video and add it to the operation queue.
 *
 * @param aURL          The URL to create download operations from.
 * @param completeBlock The block to be called when the download operations have been added to the operation queue (or an error occured).
 */
- (AFHTTPRequestOperation *)addDownloadOperationsWithURL:(NSURL *)aURL
                                           completeBlock:(TCDownloadOperationManagerAddDownloadOperationsCompleteBlock)completeBlock;

/**
 * Removes all download operations that have finished from the queue.
 * Download operations that are cancelled, failed or executing remains in 
 * the queue.
 */
- (void)removeFinishedDownloadOperations;

/**
 * Resumes a failed or cancelled download operation at the given index.
 *
 * This method does nothing if the download operation has not failed or 
 * been cancelled.
 */
- (void)resumeDownloadOperationAtIndex:(NSUInteger)index;

/**
 * Cancels a download operation at the given index.
 */
- (void)cancelDownloadOperationAtIndex:(NSUInteger)index;

/**
 * Sets the block to be called when a download operation in the operation 
 * queue has changed its state or progress.
 */
- (void)setDownloadOperationDidChangeBlock:(TCDownloadOperationManagerDownloadOperationDidChangeBlock)block;

@end
