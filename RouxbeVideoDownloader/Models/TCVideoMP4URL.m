//
//  TCVideoMP4URL.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCVideoMP4URL.h"

/**
 * URL to get the MP4 version of the video rather than the default Flash video.
 * Downloading the video in MP4 makes it compatible with iOS devices.
 */
static NSString * const kMP4VideoURLString = @"http://media.rouxbe.com/itouch/mp4/%@.mp4";

@implementation TCVideoMP4URL

+ (NSURL *)mp4VideoURLFromFlashVideoURL:(NSURL *)flashVideoURL
{
    // Delete the "f4v" (Flash) file extension. We just want the filename only.
    NSString *videoFilename = [[[flashVideoURL pathComponents] lastObject] stringByDeletingPathExtension];

    // Create the URL from the template string and return the URL to the MP4 video.
    return [NSURL URLWithString:[NSString stringWithFormat:kMP4VideoURLString, videoFilename]];
}

@end
