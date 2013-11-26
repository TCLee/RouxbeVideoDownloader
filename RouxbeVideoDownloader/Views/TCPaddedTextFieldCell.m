//
//  TCPaddedTextFieldCell.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/26/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCPaddedTextFieldCell.h"

/**
 * The horizontal padding to be added to the text inside the text field.
 */
const CGFloat HORIZONTAL_PADDING = 24.0f;

@implementation TCPaddedTextFieldCell

/**
 * Returns a copy of \c aRect with the given right padding.
 */
FOUNDATION_STATIC_INLINE
NSRect TCRectWithRightPadding(NSRect aRect, CGFloat rightPadding)
{
    return NSMakeRect(aRect.origin.x,
                      aRect.origin.y,
                      aRect.size.width - rightPadding,
                      aRect.size.height);
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
    /**
     * Override this method so that padding is shown when text field
     * has focus.
     */

    [super selectWithFrame:TCRectWithRightPadding(aRect, HORIZONTAL_PADDING) inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    /**
     * Override this method so that padding is shown when text field has 
     * lost focus.
     */

    [super drawInteriorWithFrame:TCRectWithRightPadding(cellFrame, HORIZONTAL_PADDING) inView:controlView];
}

@end