//
//  TCDownloadCellView.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadCellView.h"
#import "TCDownloadOperation.h"

@interface TCDownloadCellView ()

@end

@implementation TCDownloadCellView

#pragma mark - NSTableCellView

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

    // Label text colors will not be set automatically by setBackgroundStyle:
    // when it does not use black or white color.
    // So, we override this method to set the text color manually ourselves.
    switch (backgroundStyle) {
        case NSBackgroundStyleLight:
            self.titleLabel.textColor = [self textColorForLabel:self.titleLabel downloadOperation:_downloadOperation];
            self.progressLabel.textColor = [self textColorForLabel:self.progressLabel downloadOperation:_downloadOperation];
            break;

        case NSBackgroundStyleDark:
        default:
            // Always show white text color on dark selected background.
            self.titleLabel.textColor = [NSColor whiteColor];
            self.progressLabel.textColor = [NSColor whiteColor];
            break;
    }
    [[self.progressLabel cell] setBackgroundStyle:backgroundStyle];
}

#pragma mark - Update Cell View with Download Operation

- (void)setDownloadOperation:(TCDownloadOperation *)operation
{
    _downloadOperation = operation;

    self.titleLabel.stringValue = _downloadOperation.title;
    self.progressLabel.stringValue = [_downloadOperation localizedProgressDescription];

    BOOL isIndeterminate = _downloadOperation.progress.isIndeterminate;
    [self.progressBar setIndeterminate:isIndeterminate];
    if (isIndeterminate) {
        [self.progressBar startAnimation:self];
    } else {
        self.progressBar.doubleValue = _downloadOperation.progress.fractionCompleted;
    }

    self.titleLabel.textColor = [self textColorForLabel:self.titleLabel downloadOperation:_downloadOperation];
    self.progressLabel.textColor = [self textColorForLabel:self.progressLabel downloadOperation:_downloadOperation];
    self.actionButton.image = [self iconForDownloadOperation:_downloadOperation];
}

/**
 * Returns the label's text color for the given download operation's state.
 */
- (NSColor *)textColorForLabel:(NSTextField *)label downloadOperation:(TCDownloadOperation *)downloadOperation
{
    if (downloadOperation.isFinished) {
        // Download Failed = Dark Red Color, Download Finished = Dark Green Color
        return downloadOperation.error ? [NSColor colorWithSRGBRed:0.8f green:0.0f blue:0.0f alpha:1.0f] : [NSColor colorWithSRGBRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    } else {
        // Main title uses black color. Progress subtitle uses gray color.
        return label == self.titleLabel ? [NSColor blackColor] : [NSColor grayColor];
    }
}

/**
 * Returns the action button icon for the given download operation's state.
 */
- (NSImage *)iconForDownloadOperation:(TCDownloadOperation *)downloadOperation
{
    if (downloadOperation.isFinished) {
        return downloadOperation.error ? [NSImage imageNamed:NSImageNameRefreshFreestandingTemplate] : [NSImage imageNamed:NSImageNameRevealFreestandingTemplate];
    } else if (downloadOperation.isExecuting) {
        return [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
    }

    // Download operation is waiting in the operation queue.
    // No need to perform any action, so no icon.
    return nil;
}

@end
