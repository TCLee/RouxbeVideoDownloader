//
//  TCDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"

@interface TCDownload ()

@property (nonatomic, copy, readwrite) NSProgress *progress;

@end

@implementation TCDownload

- (id)initWithSourceURL:(NSURL *)sourceURL
              groupName:(NSString *)groupName
               position:(NSUInteger)position
                   name:(NSString *)name
{
    self = [super init];

    if (self) {
        _title = name;

        _downloadDirectoryURL = [self defaultDownloadDirectoryURL];
        _sourceURL = sourceURL;

        // Pad position with zero for numbers 1 to 9, so that Finder can
        // sort it properly. (i.e. 01, 02, 03 ... 09)
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

- (void)start
{
    NSAssert(self.didChangeProgress, @"Require block handler for download progress changed.");
    NSAssert(self.didComplete, @"Require block handler for download completed.");

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.sourceURL];

    NSProgress *__autoreleasing outProgress = nil;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&outProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        // The final destination of the downloaded file.
        return self.destinationURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        self.didComplete(filePath, error);
    }];

    // Use Key-Value Observing (KVO) to observe progress and report back.
    self.progress = [outProgress copy];
    [self.progress addObserver:self
                forKeyPath:@"fractionCompleted"
                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                   context:NULL];

    // Tasks are suspended initially, so call resume to start download.
    [downloadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.progress && [keyPath isEqualToString:@"fractionCompleted"]) {
        // Make sure progress has changed significantly before reporting back.
        // Otherwise, it will be very inefficient to report back for every
        // little change.
        double oldProgressValue = [change[NSKeyValueChangeOldKey] doubleValue];
        double newProgressValue = [change[NSKeyValueChangeNewKey] doubleValue];

        // Callback when progress has changed by at least 1 percent.
        if (newProgressValue - oldProgressValue >= 0.1f) {
            self.didChangeProgress(self.progress);
        }
    }

    [super observeValueForKeyPath:keyPath
                         ofObject:object
                           change:change
                          context:context];
}

@end
