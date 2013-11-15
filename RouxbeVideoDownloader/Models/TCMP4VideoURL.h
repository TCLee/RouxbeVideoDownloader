//
//  TCMP4VideoURL.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCMP4VideoURL class provides an interface to convert a Flash video URL
 * to an equivalent MP4 video URL.
 */
@interface TCMP4VideoURL : NSObject

/**
 * Creates and returns a URL to the MP4 version of the video.
 *
 * @param urlString The video URL string.
 *
 * @return A URL to the MP4 version of the video or 
 *         \c nil if URL string is malformed.
 */
+ (NSURL *)MP4VideoURLWithString:(NSString *)urlString;

@end
