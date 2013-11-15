//
//  TCDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"
#import "TCVideoFile.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

@implementation TCDownload

- (id)initWithSourceURL:(NSURL *)sourceURL
              groupName:(NSString *)groupName
               position:(NSUInteger)position
                   name:(NSString *)name
{
    self = [super init];

    if (self) {
        _downloadDirectoryURL = [self defaultDownloadDirectoryURL];
        _sourceURL = sourceURL;

        // Pad position with zero for numbers 1 to 9, so that Finder can
        // sort it properly. (i.e. 01, 02, 03 etc...)
        // We add 1 to position so that the first position starts at 1, instead of 0.
        NSString *filename = [[NSString alloc] initWithFormat:@"%02lu - %@.mp4", position + 1, name];

        // Destination URL: <Download Directory>/<Group Name>/<File Name>
        _destinationURL = [_downloadDirectoryURL URLByAppendingPathComponent:
                           [groupName stringByAppendingPathComponent:filename]];
    }

    return self;
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

//
//- (void)startDownloadFromSourceURL:(NSURL *)sourceURL toDestinationURL:(NSURL *)destinationURL
//{
//    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
//
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.videoURL];
//
//    NSProgress *__autoreleasing progress = nil;
//    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//        return destinationURL;
//    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//        if (filePath) {
//
//        } else {
//
//        }
//    }];
//    [downloadTask resume];
//}

@end
