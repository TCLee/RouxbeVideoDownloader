//
//  TCMP4VideoURL.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMP4VideoURL.h"

/**
 * URL to get the MP4 version of the video rather than the default Flash video.
 * Downloading the video in MP4 makes it compatible with iOS devices.
 */
static NSString * const kMP4VideoURLString = @"http://media.rouxbe.com/itouch/mp4/%@.mp4";

@implementation TCMP4VideoURL

+ (NSURL *)MP4VideoURLWithString:(NSString *)urlString
{
    if (!urlString) { return nil; }

    // Delete the "f4v" (Flash) file extension. We just want the filename only.
    NSString *videoName = [[urlString lastPathComponent] stringByDeletingPathExtension];

    // Create the URL from the template string and return the URL to the MP4 video.
    return [NSURL URLWithString:[NSString stringWithFormat:kMP4VideoURLString, videoName]];
}

@end
