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

#import "TCDownloadQueue.h"
#import "TCDownload.h"

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

/**
 * The download queue coordinates a set of download operations.
 */
@property (nonatomic, strong, readonly) TCDownloadQueue *downloadQueue;

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
- (BOOL)validateURLString:(NSString *)URLString error:(out NSError *__autoreleasing *)error;

/**
 * Return the user's Downloads directory.
 *
 * @note Raises an \c NSInternalInconsistencyException, if user's Downloads 
 *       directory could not be located.
 */
FOUNDATION_STATIC_INLINE NSURL *TCUserDownloadsDirectoryURL();

@end

@implementation TCMainWindowController

@synthesize downloadQueue = _downloadQueue;

#pragma mark - Initialize

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(tableViewDoubleClicked:)];
}

#pragma mark - URL Text Field Action

/**
 * User types in a URL and presses the Return/Enter key.
 */
- (IBAction)addDownloads:(id)sender
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

    [self.activityIndicator startAnimation:sender];

    // Create downloads from the given URL. For each download created, add it
    // to the queue.
    [TCDownload downloadsWithURL:theURL downloadDirectoryURL:TCUserDownloadsDirectoryURL() completionHandler:^(NSArray *downloads, NSError *error) {
        [self.activityIndicator stopAnimation:sender];
        
        if (downloads) {
            [self.downloadQueue addDownloads:downloads];
            [self.tableView addNumberOfRows:downloads.count];
        } else {
            // Error - Failed to create a download.
            NSAlert *alert= [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:self.window completionHandler:nil];
        }
    }];
}

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

#pragma mark - Table View Data Source & Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.downloadQueue.downloadCount;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    static NSString * const kCellIdentifier = @"TCDownloadCell";
    
    TCDownloadCellView *cellView = [tableView makeViewWithIdentifier:kCellIdentifier
                                                               owner:self];
    cellView.download = [self.downloadQueue downloadAtIndex:row];
    return cellView;
}

#pragma mark - Table View Actions

/**
 * The action button of a table view's row was clicked.
 */
- (IBAction)actionButtonClicked:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (-1 == row) { return; }

    [self performActionForDownloadAtIndex:row];
}

/**
 * Double-clicked on a table view's row.
 */
- (IBAction)tableViewDoubleClicked:(id)sender
{
    NSInteger row = [self.tableView clickedRow];
    if (-1 == row) { return; }

    [self performActionForDownloadAtIndex:row];
}

/**
 * Executes the action associated with the download at given index.
 */
- (void)performActionForDownloadAtIndex:(NSInteger)index
{
    TCDownload *download = [self.downloadQueue downloadAtIndex:index];

    switch (download.state) {
        case TCDownloadStateRunning:
            [download pause];
            break;

        case TCDownloadStatePaused:
            [download resume];
            break;

        case TCDownloadStateCompleted:
            // Show in Finder
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[download.destinationURL]];
            break;

        case TCDownloadStateFailed:
            // TODO: Restart download from where it failed.
            break;

        default:
            break;
    }

    // Reload row to update view.
    [self.tableView reloadDataAtRowIndex:index];
}

#pragma mark - Download Queue

- (TCDownloadQueue *)downloadQueue
{
    if (!_downloadQueue) {
        _downloadQueue = [[TCDownloadQueue alloc] init];

        __weak typeof(self)weakSelf = self;

        // Everytime the download's state change, we just reload the
        // table view's row to update the view.
        [_downloadQueue setDownloadStateDidChangeBlock:^(NSUInteger index) {
            if (NSNotFound != index) {
                [weakSelf.tableView reloadDataAtRowIndex:index];
            }
        }];
    }
    return _downloadQueue;
}

#pragma mark - User Downloads Directory

FOUNDATION_STATIC_INLINE NSURL *TCUserDownloadsDirectoryURL()
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [[fileManager URLsForDirectory:NSDownloadsDirectory
                                               inDomains:NSUserDomainMask] firstObject];

    if (!directoryURL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%s - User's Downloads directory should exist.", __PRETTY_FUNCTION__];
    }

    return directoryURL;
}

@end
