//
//  TCDownloadManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadManager.h"
#import "TCDownloadBuilder.h"
#import "TCDownload.h"

/**
 * The URL to the Tips & Technique embedded video player XML.
 */
static NSString * const kEmbeddedTipVideoXML = @"http://rouxbe.com/embedded_player/settings_drilldown/%ld.xml";

@interface TCDownloadManager ()

/**
 * The mutable version of our download queue for use internally only.
 */
@property (nonatomic, copy, readonly) NSMutableArray *mutableDownloadQueue;

@end

@implementation TCDownloadManager

#pragma mark - Download Queue

@synthesize mutableDownloadQueue = _mutableDownloadQueue;

- (NSMutableArray *)mutableDownloadQueue
{
    if (!_mutableDownloadQueue) {
        _mutableDownloadQueue = [[NSMutableArray alloc] init];
    }
    return _mutableDownloadQueue;
}

- (NSArray *)downloadQueue
{
    // Return the immutable copy of our download queue.
    return [self.mutableDownloadQueue copy];
}

- (void)addDownloadsWithURL:(NSURL *)aURL
{
    NSParameterAssert(aURL);

    // Download Builder will create the appropriate downloads from the given URL.
    // The handler block will be called multiple times, once for each download created.
    [TCDownloadBuilder createDownloadsWithURL:aURL handler:^(TCDownload *download, NSError *error) {
        if (download) {
            __weak typeof(self)weakSelf = self;
            __weak typeof(download)weakDownload = download;

            // Callback when this download has completed or failed.
            download.didComplete = ^(NSURL *fileURL, NSError *error) {
                if (weakSelf.downloadDidComplete) {
                    weakSelf.downloadDidComplete(weakDownload, error);
                }

                // Remove finished download from queue.
                [weakSelf.mutableDownloadQueue removeObject:weakDownload];
            };

            // Callback when this download has updated progress.
            download.didChangeProgress = ^(NSProgress *progress) {
                if (weakSelf.downloadDidChangeProgress) {
                    weakSelf.downloadDidChangeProgress(weakDownload);
                }
            };

            // Add new download to queue and start it.
            [self.mutableDownloadQueue addObject:download];
            [download start];

            if (self.didAddDownload) {
                self.didAddDownload(download, nil);
            }
        } else {
            // Error - Failed to create and add download.
            if (self.didAddDownload) {
                self.didAddDownload(nil, error);
            }
        }
    }];
}

@end
