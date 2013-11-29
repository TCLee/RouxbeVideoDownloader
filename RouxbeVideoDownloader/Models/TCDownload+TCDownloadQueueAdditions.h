//
//  TCDownloadPrivate.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/21/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"

@class AFURLConnectionByteSpeedMeasure;

@interface TCDownload ()

@property (nonatomic, copy, readwrite) NSURLSessionDownloadTask *task;

@property (nonatomic, assign, readwrite) TCDownloadState state;

@property (nonatomic, copy, readwrite) NSError *error;

/**
 * The \c AFURLConnectionByteSpeedMeasure object to calculate download speed and 
 * estimated completion time.
 */
@property (nonatomic, strong, readonly) AFURLConnectionByteSpeedMeasure *speedMeasure;

/**
 * Set the download progress's properties with the specified values.
 */
- (void)setProgressWithBytesWritten:(int64_t)bytesWritten
                  totalBytesWritten:(int64_t)totalBytesWritten
          totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
                          timestamp:(NSDate *)timestamp;

@end
