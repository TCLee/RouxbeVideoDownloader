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
    NSAssert(self.didAddDownload, @"Require block handler for download added to download queue.");
    NSAssert(self.downloadDidChangeProgress, @"Require block handler for download progress.");
    NSAssert(self.downloadDidComplete, @"Require block handler for download completed.");

    // Download Builder will create the appropriate downloads from the given URL.
    // The handler block will be called multiple times, once for each download created.
    [TCDownloadBuilder createDownloadsWithURL:aURL handler:^(TCDownload *download, NSError *error) {
        if (download) {
            // Add new download to queue.
            [self.mutableDownloadQueue addObject:download];
            self.didAddDownload(download, nil);

            // Callback blocks for download completion and progress.
            __weak typeof(download)weakDownload = download;
            download.didComplete = ^(NSURL *fileURL, NSError *error) {
                self.downloadDidComplete(weakDownload, error);
            };
            download.didChangeProgress = ^(NSProgress *progress) {
                self.downloadDidChangeProgress(weakDownload);
            };

            // Start the newly added download.
            [download start];
        } else {
            // Error - Failed to add download.
            self.didAddDownload(nil, error);
        }
    }];
}

@end
