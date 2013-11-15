//
//  TCMainWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMainWindowController.h"
#import "TCDownloadCellView.h"

#import "TCDownloadManager.h"
#import "TCDownload.h"

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

/**
 * The download manager manages the queue of video downloads.
 *
 * This window controller is the delegate object of the download manager
 * and will receive callbacks for download related events.
 */
@property (nonatomic, strong, readonly) TCDownloadManager *downloadManager;

@end

@implementation TCMainWindowController

@synthesize downloadManager = _downloadManager;

#pragma mark - Initialize From NIB

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
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

    // Make sure the URL is provided by the user.
    if (0 == urlString.length) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSInformationalAlertStyle;
        alert.messageText = @"No URL Provided";
        alert.informativeText = @"You must provide a URL for the download.";
        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    // If URL is valid, add downloads to the download queue.
    if (url) {
        [self.downloadManager addDownloadsWithURL:url];
    }
}

#pragma mark - Table View Data Source & Delegate

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

#pragma mark - Download Manager

// Download manager object will be lazily created when it's first accessed and
// then cached after that.
- (TCDownloadManager *)downloadManager
{
    // Download Manager only needs to be created and initialized once.
    if (_downloadManager) { return _downloadManager; }

    _downloadManager = [[TCDownloadManager alloc] init];

    // Create the weak references to avoid a strong reference cycle.
    __weak typeof(self)weakSelf = self;
    __weak typeof(_downloadManager)weakDownloadManager = _downloadManager;

    // Block that will be called when Download Manager has added a new Download.
    [_downloadManager setDidAddDownload:^(TCDownload *download, NSError *error) {
        if (download) {
            // Find the index of the new download.
            NSUInteger downloadIndex = [weakDownloadManager.downloadQueue indexOfObject:download];

            // Insert new row for download with an animation.
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:downloadIndex]
                                  withAnimation:NSTableViewAnimationSlideDown];
            [weakSelf.tableView scrollRowToVisible:downloadIndex];
            [weakSelf.tableView endUpdates];
        } else {
            // Error - Failed to add download.
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:weakSelf.window completionHandler:nil];
        }
    }];

    // Block that will be called when a Download has made progress.
    [_downloadManager setDownloadDidChangeProgress:^(TCDownload *download) {
        // Reload only that specified cell to update the progress bar.
        NSUInteger downloadIndex = [weakDownloadManager.downloadQueue indexOfObject:download];
        [weakSelf.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:downloadIndex]
                                  columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }];

    // Block that will be called when a Download has completed.
    [_downloadManager setDownloadDidComplete:^(TCDownload *download, NSError *error) {
        // Remove download row when it has completed.
        NSUInteger downloadIndex = [weakDownloadManager.downloadQueue indexOfObject:download];
        [weakSelf.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:downloadIndex]
                              withAnimation:NSTableViewAnimationSlideUp];

        // The only way to know if there's an error is to check the NSError
        // object. This is not considered good practice by Apple, but
        // Apple's own NSURLSessionTaskDelegate is implemented that way.
        if (error) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:weakSelf.window completionHandler:nil];
        }
    }];

    return _downloadManager;
}

@end
