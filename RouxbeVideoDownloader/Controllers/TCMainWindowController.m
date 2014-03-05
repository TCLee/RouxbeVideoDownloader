//
//  TCMainWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMainWindowController.h"

#import "NSTableView+RowAdditions.h"
#import "TCDownloadCellView.h"

#import "TCDownloadConfiguration.h"
#import "TCDownloadOperationManager.h"
#import "TCDownloadOperation.h"

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) TCDownloadOperationManager *downloadManager;

@end

@implementation TCMainWindowController

#pragma mark - Initialize

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Perform an action when user double-clicks a row in the table view.
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(tableViewDoubleClicked:)];
}

#pragma mark - URL Text Field Action

/**
 * User types in a URL and presses the Return/Enter key.
 */
- (IBAction)urlTextFieldEnterPressed:(id)sender
{
    // Make sure the action is sent by the URL text field.
    if (sender != self.urlTextField) { return; }

    NSString *URLString = self.urlTextField.stringValue;
    NSError *__autoreleasing error = nil;

    // Error - Failed to create URL object.
    if (![self validateURLString:URLString error:&error]) {
        NSAlert *alert= [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        return;
    }

    NSURL *theURL = [[NSURL alloc] initWithString:URLString];

    // Show the spinning activity indicator on the text field until the
    // download operations have been added to the queue.
    [self.activityIndicator startAnimation:sender];

    __weak typeof(self) weakSelf = self;

    // Create the download operations from the URL and add it to the operation queue.
    [self.downloadManager addDownloadOperationsWithURL:theURL completeBlock:^(NSArray *newDownloadOperations, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        [strongSelf.activityIndicator stopAnimation:sender];

        if (newDownloadOperations) {
            [strongSelf.tableView addNumberOfRows:newDownloadOperations.count];
        } else {
            NSAlert *alert= [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:strongSelf.window completionHandler:nil];
        }
    }];
}

/**
 * Returns a Boolean value that indicates whether the URL string is a
 * valid URL or not.
 *
 * @param URLString The string representing the URL.
 * @param error     The error object will contain the description of the error or
 *                  \c nil if there's no error.
 *
 * @return \c YES if \c URLString is valid; \c NO otherwise.
 */
- (BOOL)validateURLString:(NSString *)URLString
                    error:(out NSError *__autoreleasing *)error
{
    // Make sure the URL is provided by the user.
    if (nil == URLString || 0 == URLString.length) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                code:NSURLErrorBadURL
                                            userInfo:@{NSLocalizedDescriptionKey: @"No URL Provided",
                                                       NSLocalizedRecoverySuggestionErrorKey: @"You must provide a URL for the download."}];
        }
        return NO;
    }

    NSURL *theURL = [[NSURL alloc] initWithString:URLString];

    // If NSURL object could not be created due to malform URL string,
    // report error and return.
    if (!theURL) {
        if (error) {
            *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                code:NSURLErrorBadURL
                                            userInfo:@{NSLocalizedDescriptionKey: @"Malformed URL",
                                                       NSLocalizedRecoverySuggestionErrorKey: @"The URL must only contain valid characters."}];
        }
        return NO;
    }

    return YES;
}

#pragma mark - Clear Completed Downloads

/**
 * User clicks the Clear button to remove finished downloads.
 */
- (IBAction)clearButtonClicked:(id)sender
{
    [self.downloadManager removeFinishedDownloadOperations];
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source & Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.downloadManager.downloadOperationCount;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    static NSString * const kCellIdentifier = @"TCDownloadCell";
    
    TCDownloadCellView *cellView = [tableView makeViewWithIdentifier:kCellIdentifier
                                                               owner:self];
    cellView.downloadOperation = [self.downloadManager downloadOperationAtIndex:row];
    return cellView;
}

#pragma mark - Table View Actions

/**
 * The action button of a table view's row was clicked.
 */
- (IBAction)actionButtonClicked:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        [self performActionForRow:row];
    }
}

/**
 * Double-clicked on a table view's row. This will perform the action for
 * all currently selected rows in the table view.
 */
- (IBAction)tableViewDoubleClicked:(id)sender
{
    NSIndexSet *selectedRows = [self.tableView selectedRowIndexes];
    [selectedRows enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        [self performActionForRow:index];
    }];
}

/**
 * Executes the action associated with the download at given 
 * table view's row index.
 */
- (void)performActionForRow:(NSInteger)row
{
    TCDownloadOperation *downloadOperation = [self.downloadManager downloadOperationAtIndex:row];

    // Download operation is waiting for its turn in the operation queue.
    // No need to perform any action in this state.
    if (downloadOperation.isReady) { return; }

    if (downloadOperation.isExecuting) {
        [self.downloadManager cancelDownloadOperationAtIndex:row];
    } else if (downloadOperation.isFinished) {
        if (downloadOperation.error) {
            // Download Failed (or Cancelled) - Resume download from where it stopped.
            [self.downloadManager resumeDownloadOperationAtIndex:row];
        } else {
            // Download Completed - Show in Finder.
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[downloadOperation.destinationURL]];
        }
    }

    // Update the cell view at given row.
    [self.tableView reloadDataAtRowIndex:row];
}

#pragma mark - Download Operation Manager

- (TCDownloadOperationManager *)downloadManager
{
    if (!_downloadManager) {
        TCDownloadConfiguration *configuration = [TCDownloadConfiguration sharedConfiguration];
        _downloadManager = [[TCDownloadOperationManager alloc] initWithConfiguration:configuration];

        __weak typeof(self) weakSelf = self;
        [_downloadManager setDownloadOperationDidChangeBlock:^(NSUInteger index) {
            [weakSelf.tableView reloadDataAtRowIndex:index];
        }];
    }
    return _downloadManager;
}

@end
