//
//  TCDownloadCellView.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * A \c TCDownloadCellView class is a table cell view that displays the
 * download progress.
 */
@interface TCDownloadCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *progressLabel;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressBar;
@property (nonatomic, weak) IBOutlet NSButton *actionButton;

@end
