//
//  TCDownloadOperation.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/29/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "AFDownloadRequestOperation.h"

@class TCDownloadOperation;

/**
 * The prototype of the block that will be called when a download
 * operation's state or progress has changed.
 *
 * @param operation The download operation whose state or progress has changed.
 */
typedef void(^TCDownloadOperationBlock)(TCDownloadOperation *operation);

/**
 * \c TCDownloadOperation class represents a download operation that will be 
 * added to an operation queue (an instance of \c NSOperationQueue).
 */
@interface TCDownloadOperation : AFDownloadRequestOperation

/**
 * The destination URL to save the downloaded file to.
 */
@property (readonly, nonatomic, copy) NSURL *destinationURL;

/**
 * The title of the download to be displayed on a view.
 */
@property (readonly, nonatomic, copy) NSString *title;

/**
 * The \c NSProgress object that reports the download progress.
 */
@property (readonly, nonatomic, strong) NSProgress *progress;

/**
 * Initializes a newly allocated download operation with the given 
 * URL request, destination URL and title.
 *
 * @param theRequest     The URL request to load.
 * @param destinationURL The file URL to save the downloaded file to.
 * @param title          The title of the download to be presented on a view.
 *
 * @return A \c TCDownloadOperation object or \c nil if the download operation
 *         could not create the destination directory to contain the 
 *         downloaded file.
 */
- (instancetype)initWithRequest:(NSURLRequest *)theRequest
                 destinationURL:(NSURL *)destinationURL
                          title:(NSString *)title;

/**
 * Returns a localized description of the download operation's 
 * progress and state.
 *
 * Returns an empty string, if it fails to generate the description string.
 */
- (NSString *)localizedProgressDescription;

/**
 * Sets the block to be called when this download operation has started.
 */
- (void)setDidStartBlock:(TCDownloadOperationBlock)block;

/**
 * Sets the block to be called when this download operation has updated 
 * its progress.
 */
- (void)setDidUpdateProgressBlock:(TCDownloadOperationBlock)block;

/**
 * Sets the block to be called when this download operation has finished.
 */
- (void)setDidFinishBlock:(TCDownloadOperationBlock)block;

/**
 * Sets the block to be called when this download operation has failed 
 * with an error.
 */
- (void)setDidFailBlock:(TCDownloadOperationBlock)block;

@end
