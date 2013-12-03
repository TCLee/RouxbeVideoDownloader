//
//  TCDownloadCellView.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;
@class TCDownloadOperation;

/**
 * A table cell view that renders a download model's state and progress.
 */
@interface TCDownloadCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *progressLabel;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressBar;
@property (nonatomic, weak) IBOutlet NSButton *actionButton;

/**
 * The \c TCDownloadOperation object that will be rendered by this cell view.
 */
@property (nonatomic, strong) TCDownloadOperation *downloadOperation;

@end
