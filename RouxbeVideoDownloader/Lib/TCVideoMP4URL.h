//
//  TCVideoMP4URL.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCVideoMP4URL class provides an interface to convert a Flash video URL
 * to an equivalent MP4 video URL.
 *
 * This method is extracted to a class to make it re-usable.
 */
@interface TCVideoMP4URL : NSObject

/**
 * Returns a MP4 video URL from the given Flash video URL.
 *
 * @param flashVideoURL The URL to the Flash video.
 *
 * @return A \c NSURL instance referencing the MP4 video.
 */
+ (NSURL *)mp4VideoURLFromFlashVideoURL:(NSURL *)flashVideoURL;

@end
