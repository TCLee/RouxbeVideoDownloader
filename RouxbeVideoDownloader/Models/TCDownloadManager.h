//
//  TCDownloadManager.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadManager;
@class TCDownload;

@protocol TCDownloadManagerDelegate <NSObject>

@required

- (void)downloadManager:(TCDownloadManager *)downloadManager
  didAddDownloadAtIndex:(NSUInteger)index;

- (void)downloadManager:(TCDownloadManager *)downloadManager
downloadProgressChangedAtIndex:(NSUInteger)index;

- (void)downloadManager:(TCDownloadManager *)downloadManager
downloadCompletedAtIndex:(NSUInteger)index;

- (void)downloadManager:(TCDownloadManager *)downloadManager
        downloadAtIndex:(NSUInteger)index
       didFailWithError:(NSError *)error;

@end


/**
 * \c TCDownloadManager manages a queue of video downloads. Each video download
 * is represented by a \c TCDownload object.
 */
@interface TCDownloadManager : NSObject

/**
 * The delegate object that will receive callbacks of the download progress
 * and status.
 */
@property (nonatomic, weak, readonly) id<TCDownloadManagerDelegate> delegate;

/**
 * The download queue contains all the downloads that are in progress.
 */
@property (nonatomic, copy, readonly) NSArray *downloadQueue;

/**
 * Initializes a new download manager with the given delegate for callbacks.
 *
 * @param delegate The download manager delegate object that will receive 
 *                 callbacks for download related events.
 *
 * @return An initialized \c TCDownloadManager object.
 */
- (id)initWithDelegate:(id<TCDownloadManagerDelegate>)delegate;

/**
 * Add one or more video downloads to the queue with the given URL.
 * A URL may point to a resource with a collection of videos or just one video.
 *
 * If downloads are already in progress for the given URL, the downloads will 
 * not be added to the queue again.
 *
 * @param url The URL to the resource that contains a collection of one 
 *            or more videos.
 */
- (void)addDownloadsWithURL:(NSURL *)url;

@end
