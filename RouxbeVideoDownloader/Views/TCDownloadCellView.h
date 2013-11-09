//
//  TCDownloadCellView.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/8/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownload;

/**
 * \c TCDownloadCellView class renders the current state of a 
 * \c TCDownload model object.
 */
@interface TCDownloadCellView : NSTableCellView

@property (nonatomic, weak) IBOutlet NSTextField *titleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *progressLabel;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressBar;

/**
 * The \c TCDownload object describing the download.
 */
@property (nonatomic, strong) TCDownload *download;

/**
 * The \c NSProgress object describing the current download progress.
 */
@property (nonatomic, strong) NSProgress *progress;

@end
