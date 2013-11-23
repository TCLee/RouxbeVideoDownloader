//
//  TCDownloadCellView.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadCellView.h"
#import "TCDownload.h"

@implementation TCDownloadCellView

- (void)setDownload:(TCDownload *)download
{
    _download = download;

    self.titleLabel.stringValue = _download.description;
    self.progressBar.doubleValue = _download.progress.fractionCompleted;

    switch (_download.state) {
        case TCDownloadStateRunning:
            [self configureViewForRunningDownload:_download];
            break;

        case TCDownloadStatePaused:
            [self configureViewForPausedDownload:_download];
            break;

        case TCDownloadStateCompleted:
            [self configureViewForCompletedDownload:_download];
            break;

        case TCDownloadStateFailed:
            [self configureViewForFailedDownload:_download];
            break;

        default:
            break;
    }
}

- (void)configureViewForRunningDownload:(TCDownload *)download
{
    self.progressLabel.stringValue = [download.progress localizedAdditionalDescription];
    self.progressLabel.textColor = [NSColor grayColor];
    self.actionButton.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
}

- (void)configureViewForPausedDownload:(TCDownload *)download
{
    self.progressLabel.stringValue = NSLocalizedString(@"Paused", @"");
    self.progressLabel.textColor = [NSColor grayColor];
    self.actionButton.image = [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
}

- (void)configureViewForCompletedDownload:(TCDownload *)download
{
    self.progressLabel.stringValue = NSLocalizedString(@"Completed", @"");
    self.progressLabel.textColor = [NSColor greenColor];
    self.actionButton.image = [NSImage imageNamed:NSImageNameRevealFreestandingTemplate];
}

- (void)configureViewForFailedDownload:(TCDownload *)download
{
    self.progressLabel.stringValue = [NSString stringWithFormat:@"Error: %@", download.error];
    self.progressLabel.textColor = [NSColor redColor];
    self.actionButton.image = [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
}

@end
