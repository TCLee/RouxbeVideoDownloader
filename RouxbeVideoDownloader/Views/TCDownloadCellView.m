//
//  TCDownloadCellView.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadCellView.h"
#import "TCDownload.h"

@interface TCDownloadCellView ()

@end

@implementation TCDownloadCellView

#pragma mark - Overridden Methods

- (void)awakeFromNib
{
    [super awakeFromNib];

    // Disable highlight of the action button when it's clicked. Otherwise,
    // the action button's icon will have a higlighted background, which makes
    // it look ugly.
    [self.actionButton.cell setHighlightsBy:NSNoCellMask];
}

- (void)setBackgroundStyle:(NSBackgroundStyle)backgroundStyle
{
    [super setBackgroundStyle:backgroundStyle];

    // Progress label text color will not be set automatically by
    // setBackgroundStyle: because it does not use black or white color.
    // So, we override this method to set it manually ourselves.
    switch (backgroundStyle) {
        case NSBackgroundStyleLight:
            self.progressLabel.textColor = [self textColorForDownloadState:self.download.state];
            break;

        case NSBackgroundStyleDark:
        default:
            // Always show white text color on dark selected background.
            self.progressLabel.textColor = [NSColor whiteColor];
            break;
    }
    [[self.progressLabel cell] setBackgroundStyle:backgroundStyle];
}

#pragma mark - Update View for Download

- (void)setDownload:(TCDownload *)download
{
    _download = download;

    self.titleLabel.stringValue = _download.description;
    self.progressBar.doubleValue = _download.progress.fractionCompleted;
    self.progressLabel.stringValue = [_download localizedProgressDescription];

    self.progressLabel.textColor = [self textColorForDownloadState:_download.state];
    self.actionButton.image = [self iconForDownloadState:_download.state];
}

- (NSColor *)textColorForDownloadState:(TCDownloadState)state
{
    switch (state) {
        case TCDownloadStateCompleted:
            // Dark Green Color
            return [NSColor colorWithSRGBRed:0.0f green:0.5f blue:0.0f alpha:1.0f];

        case TCDownloadStateFailed:
            return [NSColor redColor];

        case TCDownloadStateRunning:
        case TCDownloadStatePaused:
        default:
            return [NSColor grayColor];
    }
}

- (NSImage *)iconForDownloadState:(TCDownloadState)state
{
    switch (state) {
        case TCDownloadStateRunning:
            return [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];

        case TCDownloadStateCompleted:
            return [NSImage imageNamed:NSImageNameRevealFreestandingTemplate];

        case TCDownloadStatePaused:
        case TCDownloadStateFailed:
        default:
            return [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];;
    }
}

@end
