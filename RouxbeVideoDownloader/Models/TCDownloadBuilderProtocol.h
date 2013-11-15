//
//  TCDownloadBuilderProtocol.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;

/**
 * The block that will be called when a download has been created.
 *
 * @param download The \c TCDownload object that was created.
 * @param error    The \c NSError object describing the error, if any.
 */
typedef void(^TCDownloadBuilderBlock)(TCDownload *download, NSError *error);

/**
 * All download builders must conform to this protocol.
 */
@protocol TCDownloadBuilderProtocol <NSObject>

/**
 * Creates downloads from the given URL.
 *
 * @param aURL    The URL to create the downloads from.
 * @param handler The handler block that will be called for each download created.
 */
+ (void)createDownloadsWithURL:(NSURL *)aURL
                       handler:(TCDownloadBuilderBlock)handler;

@end
