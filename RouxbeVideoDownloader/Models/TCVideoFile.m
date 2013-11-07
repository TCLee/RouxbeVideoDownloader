//
//  TCVideoFile.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCVideoFile.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

@implementation TCVideoFile

- (id)initWithLessonStep:(TCLessonStep *)lessonStep
{
    self = [super init];

    if (self) {
        // Each lesson's step will be saved under a directory with the lesson's name.
        _directoryName = [lessonStep.lesson.name copy];
        _filename = [self filenameWithName:lessonStep.name
                                  position:lessonStep.position];
    }

    return self;
}

- (NSURL *)fileURL
{
    // Use the user's default Downloads directory, if no download directory provided.
    NSURL *downloadDirectory = _downloadDirectoryURL ?: [self defaultDownloadDirectoryURL];

    return [downloadDirectory URLByAppendingPathComponent:
            [_directoryName stringByAppendingPathComponent:_filename]];
}

/**
 * Returns the user's default Downloads directory.
 *
 * @return The URL to the user's Downloads directory.
 */
- (NSURL *)defaultDownloadDirectoryURL
{
    NSURL *downloadDirectoryURL = [[[NSFileManager defaultManager]
                                    URLsForDirectory:NSDownloadsDirectory
                                    inDomains:NSUserDomainMask] firstObject];

    NSAssert(downloadDirectoryURL, @"Could not locate the Downloads directory.");
    return downloadDirectoryURL;
}

/**
 * Returns a formatted string for the video's filename with the given name 
 * and position.
 *
 * \b Example: Given the name "Hello World" and position 1, the filename
 * returned will be "02 - Hello World.mp4".
 *
 * @param name     The name of the video file.
 * @param position The position of the video file. First position starts at zero.
 *
 * @return A formatted string for the video's filename.
 */
- (NSString *)filenameWithName:(NSString *)name position:(NSUInteger)position
{
    // Position is zero-based, so we add 1 to make it start from 1.
    // We also pad it with zero for numbers 0 to 9, so that Finder can
    // sort it properly.
    return [NSString stringWithFormat:@"%02lu - %@.mp4", position + 1, name];
}

@end
