//
//  TCMainWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMainWindowController.h"
#import "TCDownloadController.h"

#import "NSTableView+RowAdditions.h"
#import "TCDownloadCellView.h"

#import "TCDownloadQueue.h"
#import "TCDownload.h"

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong, readonly) TCDownloadController *downloadController;
@property (nonatomic, strong, readonly) TCDownloadQueue *downloadQueue;

@end

@implementation TCMainWindowController

@synthesize downloadController = _downloadController;

#pragma mark - Initialize From NIB

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
}

#pragma mark - URL Text Field Action

/**
 * User types in a URL and presses the Return/Enter key.
 */
- (IBAction)downloadVideos:(id)sender
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
    __weak typeof(self)weakSelf = self;

    [self.downloadController addDownloadsWithURL:theURL success:^{
        // Add a new row to the table view for each new download added
        // to the queue.
        [weakSelf.tableView addRow];
    } failure:^(NSError *error) {
        // Error - Failed to add downloads.
        NSAlert *alert= [NSAlert alertWithError:error];
        [alert beginSheetModalForWindow:weakSelf.window completionHandler:nil];
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
- (BOOL)validateURLString:(NSString *)URLString error:(NSError *__autoreleasing *)error
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

    TCDownload *download = [self.downloadQueue downloadAtIndex:row];
    cellView.titleLabel.stringValue = download.description;

    if (download.progress) {
        // Download has started, so update the cell's progress views.
        cellView.progressLabel.stringValue = [download.progress localizedAdditionalDescription];
        cellView.progressBar.doubleValue = download.progress.fractionCompleted;
    } else {
        // Download has been queued but not started yet.
        cellView.progressLabel.stringValue = NSLocalizedString(@"Download Not Started", @"");
        cellView.progressBar.doubleValue = 0;
    }
    
    return cellView;
}

#pragma mark - Download Controller

- (TCDownloadController *)downloadController
{
    if (!_downloadController) {
        _downloadController = [[TCDownloadController alloc] init];

        __weak typeof(self)weakSelf = self;

        [_downloadController.downloadQueue setDownloadDidChangeProgressBlock:^(NSUInteger index) {
            if (NSNotFound == index) { return; }

            // Reload row to update progress.
            [weakSelf.tableView reloadDataAtRowIndex:index];
        }];

        [_downloadController.downloadQueue setDownloadDidFinishBlock:^(NSUInteger index) {
            if (NSNotFound == index) { return; }

            // Remove finished download.
            [weakSelf.tableView removeRowAtIndex:index];
        }];

        [_downloadController.downloadQueue setDownloadDidFailBlock:^(NSUInteger index, NSError *error) {
            if (NSNotFound == index) { return; }

            NSAlert *alert = [NSAlert alertWithError:error];
            [alert beginSheetModalForWindow:weakSelf.window completionHandler:^(NSModalResponse returnCode) {
                if (NSModalResponseStop == returnCode) {
                    // Remove failed download.
                    [weakSelf.tableView removeRowAtIndex:index];
                }
            }];
        }];
    }

    return _downloadController;
}

- (TCDownloadQueue *)downloadQueue
{
    return self.downloadController.downloadQueue;
}

@end
