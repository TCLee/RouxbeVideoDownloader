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

@property (nonatomic, strong, readwrite) NSURLSessionDownloadTask *task;

@property (nonatomic, assign, readwrite) TCDownloadState state;

@property (nonatomic, strong, readonly) AFURLConnectionByteSpeedMeasure *speedMeasure;

@end
