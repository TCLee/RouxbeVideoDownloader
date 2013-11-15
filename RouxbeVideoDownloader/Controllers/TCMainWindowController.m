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

    // Make sure the URL is not empty.
    if (0 == urlString.length) {
        [self showAlertWithStyle:NSInformationalAlertStyle
                           title:@"No URL Provided"
                 informativeText:@"You must provide a URL for the download."
              defaultButtonTitle:@"OK"];
        return;
    }

    NSURL *url = [[NSURL alloc] initWithString:urlString];
    // If URL is valid, add downloads to the download queue.
    if (url) {
        [self.downloadManager addDownloadsWithURL:url];
    }
}

/**
 * Convenience method to show an NSAlert with given values.
 *
 * @param style              The \c NSAlertStyle constant for the alert's style.
 * @param title              Title of the alert.
 * @param text               Informative text for the alert.
 * @param defaultButtonTitle Title for the default button.
 */
- (void)showAlertWithStyle:(NSAlertStyle)style
                     title:(NSString *)title
           informativeText:(NSString *)text
        defaultButtonTitle:(NSString *)defaultButtonTitle
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = style;
    alert.messageText = title;
    alert.informativeText = text;
    [alert addButtonWithTitle:defaultButtonTitle];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
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
    if (!_downloadManager) {
        _downloadManager = [[TCDownloadManager alloc] initWithDelegate:self];
    }
    return _downloadManager;
}

#pragma mark - Download Manager Delegate

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
didFailToAddDownloadWithError:(NSError *)error
{
    // Show alert view to let user know why we failed to add the downloads.
    NSAlert *alert = [NSAlert alertWithError:error];
    [alert beginSheetModalForWindow:self.window completionHandler:nil];
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
