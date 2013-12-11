//
//  NSTableView+RowAdditions.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/21/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "NSTableView+RowAdditions.h"

@implementation NSTableView (RowAdditions)

- (void)addNumberOfRows:(NSUInteger)rowCount
{
    // <Last Row Index> + 1 == <Number of Rows>
    NSInteger indexOfFirstNewRow = self.numberOfRows;
    NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:
                           NSMakeRange(indexOfFirstNewRow, rowCount)];

    [self beginUpdates];
    [self insertRowsAtIndexes:indexes
                withAnimation:NSTableViewAnimationSlideDown];
    [self scrollRowToVisible:indexOfFirstNewRow];
    [self endUpdates];
}

- (void)reloadDataAtRowIndex:(NSUInteger)rowIndex
{
    [self reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:rowIndex]
                    columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

@end