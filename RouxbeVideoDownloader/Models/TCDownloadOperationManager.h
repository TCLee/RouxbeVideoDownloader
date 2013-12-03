//
//  TCDownloadOperationManager.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/30/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadConfiguration;
@class TCDownloadOperation;

typedef void(^TCDownloadOperationManagerAddDownloadsCompleteBlock)(NSArray *newDownloadOperations, NSError *error);
typedef void(^TCDownloadOperationManagerAddDownloadsErrorBlock)(NSError *error);

typedef void(^TCDownloadOperationManagerDownloadProgressBlock)(NSUInteger index);

@interface TCDownloadOperationManager : NSObject

/**
 * A copy of the configuration object used to configure the behavior of 
 * a \c TCDownloadOperationManager.
 */
@property (readonly, nonatomic, copy) TCDownloadConfiguration *configuration;

/**
 * Initializes a \c TCDownloadOperationManager with the given configuration.
 */
- (instancetype)initWithConfiguration:(TCDownloadConfiguration *)configuration;

/**
 * The number of download operations that is managed by this 
 * \c TCDownloadOperationManager.
 */
- (NSUInteger)downloadOperationCount;

/**
 * Returns the download operation at the specified index.
 */
- (TCDownloadOperation *)downloadOperationAtIndex:(NSUInteger)index;

- (void)addDownloadOperationsWithURL:(NSURL *)aURL
                       completeBlock:(TCDownloadOperationManagerAddDownloadsCompleteBlock)completeBlock;

- (void)resumeFailedDownloadOperationAtIndex:(NSUInteger)index;

- (void)setDownloadOperationProgressBlock:(TCDownloadOperationManagerDownloadProgressBlock)block;

@end
