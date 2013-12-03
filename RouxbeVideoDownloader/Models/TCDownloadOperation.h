//
//  TCDownloadV2.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/29/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "AFDownloadRequestOperation.h"

@class TCDownloadOperation;

typedef void(^TCDownloadOperationProgressChangedBlock)(TCDownloadOperation *operation);

/**
 * \c TCDownloadOperation class represents a download operation that will be 
 * added to an operation queue (an instance of \c NSOperationQueue).
 */
@interface TCDownloadOperation : AFDownloadRequestOperation

/**
 * The destination URL to save the downloaded file to.
 */
@property (nonatomic, copy, readonly) NSURL *destinationURL;

/**
 * The title of the download to be displayed on a view.
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 * A copy of the \c NSProgress object that reports the download progress.
 */
@property (nonatomic, copy, readonly) NSProgress *progress;

- (instancetype)initWithSourceURL:(NSURL *)sourceURL
                   destinationURL:(NSURL *)destinationURL
                            title:(NSString *)title;

- (NSString *)localizedProgressDescription;

- (void)setProgressChangedBlock:(TCDownloadOperationProgressChangedBlock)block;

@end
