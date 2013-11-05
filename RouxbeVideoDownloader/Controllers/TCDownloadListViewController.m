//
//  TCDownloadListViewController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadListViewController.h"

@interface TCDownloadListViewController ()

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

@implementation TCDownloadListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 5;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSView *resultView = [tableView makeViewWithIdentifier:@"DownloadCell" owner:self];
    return resultView;
}

@end
