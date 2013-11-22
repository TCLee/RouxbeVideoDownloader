//
//  TCDownloadController.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/22/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadQueue;

typedef void(^TCDownloadControllerSuccessBlock)(void);
typedef void(^TCDownloadControllerFailureBlock)(NSError *error);

/**
 * \c TCDownloadController class coordinates the various model objects
 * that are involved in the download workflow.
 */
@interface TCDownloadController : NSObject

/**
 * The download queue that coordinates the download operations.
 */
@property (nonatomic, strong, readonly) TCDownloadQueue *downloadQueue;

/**
 * Search for videos from the given URL. For each video found, create a 
 * download and add it to the download queue.
 *
 * @param theURL   The URL to search for videos to download.
 * @param success  The block to be called each time a download has been
 *                 added to the download queue.
 * @param failure  The block to be called when an error has occured. 
 *                 The error object argument will contain the description of the
 *                 error.
 */
- (void)addDownloadsWithURL:(NSURL *)theURL
                    success:(TCDownloadControllerSuccessBlock)success
                    failure:(TCDownloadControllerFailureBlock)failure;

@end
