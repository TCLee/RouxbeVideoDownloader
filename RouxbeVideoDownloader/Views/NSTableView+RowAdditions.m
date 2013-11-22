//
//  NSTableView+RowAdditions.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/21/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "NSTableView+RowAdditions.h"

@implementation NSTableView (RowAdditions)

- (void)addRow
{
    // <Last Row Index> + 1 == <Number of Rows>
    NSInteger newRowIndex = self.numberOfRows;

    [self beginUpdates];
    [self insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex]
                withAnimation:NSTableViewAnimationSlideDown];
    [self scrollRowToVisible:newRowIndex];
    [self endUpdates];
}

- (void)removeRowAtIndex:(NSUInteger)rowIndex
{
    [self removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                withAnimation:NSTableViewAnimationSlideUp];
}

- (void)reloadDataAtRowIndex:(NSUInteger)rowIndex
{
    [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                    columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

@end