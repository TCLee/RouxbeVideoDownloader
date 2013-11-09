//
//  TCMainWindowController.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadManager.h"

/**
 * This is a single-window app, so we only have one window controller.
 */
@interface TCMainWindowController : NSWindowController
    <NSTableViewDataSource, NSTableViewDelegate, TCDownloadManagerDelegate>

@end
