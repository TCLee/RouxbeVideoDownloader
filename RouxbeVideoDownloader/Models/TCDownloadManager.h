//
//  TCDownloadManager.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;

typedef void(^TCDownloadManagerAddDownloadBlock)(TCDownload *download, NSError *error);
typedef void(^TCDownloadManagerDownloadProgressBlock)(TCDownload *download);
typedef void(^TCDownloadManagerDownloadCompleteBlock)(TCDownload *download, NSError *error);

/**
 * \c TCDownloadManager manages a queue of video downloads. Each video download
 * is represented by a \c TCDownload object.
 */
@interface TCDownloadManager : NSObject

/**
 * The download queue contains all the downloads that are in progress.
 */
@property (nonatomic, copy, readonly) NSArray *downloadQueue;

@property (nonatomic, copy, readwrite) TCDownloadManagerAddDownloadBlock didAddDownload;
@property (nonatomic, copy, readwrite) TCDownloadManagerDownloadProgressBlock downloadDidChangeProgress;
@property (nonatomic, copy, readwrite) TCDownloadManagerDownloadCompleteBlock downloadDidComplete;

/**
 * Add one or more video downloads to the queue with the given URL.
 * A URL may point to a resource with a collection of videos or just one video.
 *
 * @param url The URL to the resource that contains a collection of one
 *            or more videos.
 */
- (void)addDownloadsWithURL:(NSURL *)url;

@end
