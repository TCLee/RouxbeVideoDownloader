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

- (void)setDownload:(TCDownload *)theDownload
{
    _download = theDownload;

    // Download title.
    self.titleLabel.stringValue = _download.name;

    NSProgress *progress = _download.progress;
    if (progress) {
        // If download has started then we show its progress.
        self.progressLabel.stringValue = [progress localizedAdditionalDescription];
        self.progressBar.doubleValue = progress.fractionCompleted;
    } else {
        // Else download has been queued but not started just reset to
        // initial state.
        self.progressLabel.stringValue = NSLocalizedString(@"Not Started", @"");
        self.progressBar.doubleValue = 0;
    }
}

@end
