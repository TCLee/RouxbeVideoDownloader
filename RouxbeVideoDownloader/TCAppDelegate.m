//
//  TCAppDelegate.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/4/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCMainWindowController.h"
#import "TCPreferencesWindowController.h"
#import "TCDownloadConfiguration.h"

@interface TCAppDelegate ()

@property (readwrite, nonatomic, weak) IBOutlet TCMainWindowController *mainWindowController;
@property (readwrite, nonatomic, weak) IBOutlet TCPreferencesWindowController *preferencesWindowController;

@end

@implementation TCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.preferencesWindowController.configuration = [TCDownloadConfiguration sharedConfiguration];
    
    [self.mainWindowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    // Quit the app automatically after last window is closed.
    return YES;
}

@end
