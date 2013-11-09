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

    self.titleLabel.stringValue = _download.title;
    [self setProgress:_download.progress];
}

- (void)setProgress:(NSProgress *)theProgress
{
    _progress = theProgress;

    self.progressLabel.stringValue = [_progress localizedAdditionalDescription];
    self.progressBar.doubleValue = _progress.fractionCompleted;
}

@end
