//
//  TCDownload+TCDownloadQueueAdditions.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/21/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"

@class AFURLConnectionByteSpeedMeasure;

/**
 * \c TCDownload class category that adds private interfaces for use with
 * \c TCDownloadQueue only.
 */
@interface TCDownload (TCDownloadQueueAdditions)

/**
 * The \c NSURLSessionDownloadTask that performs the actual download.
 */
@property (readwrite, nonatomic, strong) NSURLSessionDownloadTask *task;

/**
 * The data object used to resume a failed or cancelled download.
 * This will be \c nil if download is running or has completed successfully.
 */
@property (readonly, nonatomic, copy) NSData *resumeData;

/**
 * The \c AFURLConnectionByteSpeedMeasure object to calculate download speed and
 * estimated completion time.
 */
@property (readonly, nonatomic, strong) AFURLConnectionByteSpeedMeasure *speedMeasure;

/**
 * Update the download progress calculation with the given values.
 */
- (void)setProgressWithBytesWritten:(int64_t)bytesWritten
                  totalBytesWritten:(int64_t)totalBytesWritten
          totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
                          timestamp:(NSDate *)timestamp;

/**
 * Sets the download state to be completed, if file URL is provided.
 * Otherwise, sets the download state to failed with an error object
 * describing the failure.
 */
- (void)setCompletedWithFileURL:(NSURL *)fileURL error:(NSError *)error;

/**
 * Resumes the download task, if it is suspended.
 */
- (void)resume;

/**
 * Cancels the download task. This will free up the connection for
 * the other download tasks.
 */
- (void)cancel;

- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completionHandler;

@end

