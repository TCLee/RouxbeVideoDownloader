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
 * Adds the specified number of rows to the end of the table view.
 *
 * @param rowCount The number of rows to add.
 */
- (void)addNumberOfRows:(NSUInteger)rowCount;

/**
 * Reloads the data for the row at the given index.
 */
- (void)reloadDataAtRowIndex:(NSUInteger)rowIndex;

@end
