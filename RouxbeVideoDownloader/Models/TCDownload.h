//
//  TCDownload.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCVideo;

/**
 * \c TCDownload class is responsible for downloading a video.
 */
@interface TCDownload : NSObject

/**
 * The URL to the directory that all the video files will be saved to.
 * 
 * This directory will be decided by the user, but it cannot be \c nil.
 */
@property (nonatomic, copy, readonly) NSURL *downloadDirectoryURL;

/**
 * The string that is intended for display on a view.
 */
@property (nonatomic, copy, readonly) NSString *description;

/**
 * The source URL to download the video from.
 */
@property (nonatomic, copy, readonly) NSURL *sourceURL;

/**
 * The destination URL to save the downloaded video file to.
 *
 * The destination URL is created by appending to the user provided 
 * download directory.
 *
 * @see TCDownload::downloadDirectoryURL
 */
@property (nonatomic, copy, readonly) NSURL *destinationURL;

/**
 * The current progress of the download.
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

- (id)initWithVideo:(TCVideo *)video
downloadDirectoryURL:(NSURL *)downloadDirectoryURL
        description:(NSString *)description;

@end
