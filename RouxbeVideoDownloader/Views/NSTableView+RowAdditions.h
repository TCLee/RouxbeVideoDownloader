//
//  NSTableView+RowAdditions.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/21/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c RowAdditions category adds a simpler interface to manage
 * rows of a table view.
 */
@interface NSTableView (RowAdditions)

/**
 * Adds a new row after the last row of the table view.
 */
- (void)addRow;

/**
 * Removes a row from the table view at the given index.
 */
- (void)removeRowAtIndex:(NSUInteger)rowIndex;

/**
 * Reloads the data for the row at the given index.
 */
- (void)reloadDataAtRowIndex:(NSUInteger)rowIndex;

@end
