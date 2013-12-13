//
//  TCPreferencesWindowController.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/11/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCDownloadConfiguration;

/**
 * The window controller for the preferences window. 
 * The preferences window provides an interface for the user to change
 * download settings.
 */
@interface TCPreferencesWindowController : NSWindowController

/**
 * The download configuration model object used by this controller.
 */
@property (readwrite, nonatomic, strong) TCDownloadConfiguration *configuration;

@end
