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

    // If download has started then we show its progress.
    // Else just reset to zero.
    NSProgress *progress = _download.progress;
    if (progress) {
        self.progressLabel.stringValue = [progress localizedAdditionalDescription];
        self.progressBar.doubleValue = progress.fractionCompleted;
    } else {
        self.progressLabel.stringValue = @"";
        self.progressBar.doubleValue = 0;
    }
}

@end
