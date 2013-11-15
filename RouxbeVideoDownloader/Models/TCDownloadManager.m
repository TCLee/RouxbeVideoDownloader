//
//  TCDownloadManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadManager.h"
#import "TCDownload.h"
#import "TCDownloadBuilder.h"

/**
 * The URL to the Tips & Technique embedded video player XML.
 */
static NSString * const kEmbeddedTipVideoXML = @"http://rouxbe.com/embedded_player/settings_drilldown/%ld.xml";

@interface TCDownloadManager ()

@property (nonatomic, copy, readonly) NSMutableArray *mutableDownloadQueue;

@end

@implementation TCDownloadManager

- (id)initWithDelegate:(id<TCDownloadManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (NSArray *)downloadQueue
{
    // Return the immutable copy of our download queue.
    return [self.mutableDownloadQueue copy];
}

- (void)addDownloadsWithURL:(NSURL *)aURL
{
    // Download Builder will create the appropriate downloads from the given URL.
    // The handler block will be called multiple times, once for each download created.
    [TCDownloadBuilder createDownloadsWithURL:aURL handler:^(TCDownload *download, NSError *error) {
        if (download) {
            [self.mutableDownloadQueue addObject:download];

            // Notify delegate object that we've appended a download to the queue.
            [self.delegate downloadManager:self
                     didAddDownloadAtIndex:(self.mutableDownloadQueue.count - 1)];
        } else {
            // Error - Failed to add download to download queue.
            [self.delegate downloadManager:self didFailToAddDownloadWithError:error];
        }
    }];
}

@end
