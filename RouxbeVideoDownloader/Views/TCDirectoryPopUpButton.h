//
//  TCDirectoryPopUpButton.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 2/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * Subclass of \c NSPopUpButton that shows the currently
 * selected directory and allows the user to
 * select another directory using an \c NSOpenPanel.
 */
@interface TCDirectoryPopUpButton : NSPopUpButton

/**
 * The URL of the directory that is currently selected or 
 * \c nil if no directory has been selected yet.
 *
 * You should set this property to an initial default directory of 
 * your choosing.
 */
@property (readwrite, nonatomic, copy) NSURL *selectedDirectoryURL;

@end
