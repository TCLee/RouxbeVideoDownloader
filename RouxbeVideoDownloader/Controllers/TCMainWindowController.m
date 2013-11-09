//
//  TCMainWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMainWindowController.h"
#import "TCDownloadCellView.h"
#import "TCDownload.h"

#pragma mark -

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong, readonly) TCDownloadManager *downloadManager;

@end

@implementation TCMainWindowController

@synthesize downloadManager = _downloadManager;

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
}

- (TCDownloadManager *)downloadManager
{
    if (!_downloadManager) {
        _downloadManager = [[TCDownloadManager alloc] initWithDelegate:self];
    }
    return _downloadManager;
}

#pragma mark - IBAction Methods

/**
 * Begins downloading videos from the given URL when user presses the Enter key.
 *
 * @param sender The \c NSTextField that the Enter key was pressed in.
 */
- (IBAction)downloadVideos:(id)sender
{
    // Make sure the action is sent by the URL text field.
    if (sender != self.urlTextField) { return; }

    NSString *urlString = self.urlTextField.stringValue;

    // Make sure the URL is not empty.
    if (0 == urlString.length) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"No URL Provided"
                                         defaultButton:nil
                                       alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"You must provide a URL for download."];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }

    // Add video downloads from user's given URL to the queue.
    [self.downloadManager addDownloadsWithURL:[NSURL URLWithString:urlString]];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    // Returns the number of downloads currently in progress.
    return self.downloadManager.downloadQueue.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString * const kCellIdentifier = @"TCDownloadCell";

    TCDownloadCellView *cellView = [tableView makeViewWithIdentifier:kCellIdentifier
                                                               owner:self];
    cellView.download = self.downloadManager.downloadQueue[row];
    return cellView;
}

#pragma mark - TCDownloadManager Delegate

- (void)downloadManager:(TCDownloadManager *)downloadManager
  didAddDownloadAtIndex:(NSUInteger)index
{
    // A new download has been added to the download queue.
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                          withAnimation:NSTableViewAnimationSlideDown];
    [self.tableView scrollRowToVisible:index];
    [self.tableView endUpdates];
}

- (void)downloadManager:(TCDownloadManager *)downloadManager
downloadProgressChangedAtIndex:(NSUInteger)index
{
    // Reload data for only that specified cell. If that cell is not visible,
    // nothing will happen.
    [self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index]
                              columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

- (void)downloadManager:(TCDownloadManager *)downloadManager
downloadCompletedAtIndex:(NSUInteger)index
{
    // Download has finished and is removed from download queue.
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                          withAnimation:NSTableViewAnimationSlideUp];
}

- (void)downloadManager:(TCDownloadManager *)downloadManager
        downloadAtIndex:(NSUInteger)index
       didFailWithError:(NSError *)error
{
    // Download has failed and is removed from download queue.
    [self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                          withAnimation:NSTableViewAnimationEffectFade];

    // Show alert view to let user know which download has failed.
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
}

@end
