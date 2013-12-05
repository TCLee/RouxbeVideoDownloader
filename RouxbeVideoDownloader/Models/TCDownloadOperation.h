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
typedef void(^TCDownloadOperationDidChangeBlock)(TCDownloadOperation *operation);

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
 * <#Description#>
 *
 * @param theRequest     <#theRequest description#>
 * @param destinationURL <#destinationURL description#>
 * @param title          <#title description#>
 *
 * @return \c nil if the download operation could not be created.
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
 * Sets the block to be called when this download operation's 
 * state or progress has changed.
 */
- (void)setDownloadOperationDidChange:(TCDownloadOperationDidChangeBlock)block;

@end
