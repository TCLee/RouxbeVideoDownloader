//
//  TCAppDelegate.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/4/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCMainWindowController.h"

@interface TCAppDelegate ()

@property (nonatomic, strong) TCMainWindowController *windowController;

@end

@implementation TCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Create and show the main window when app finishes launching.
    if (nil == self.windowController) {
        self.windowController = [[TCMainWindowController alloc] init];
    }
    [self.windowController showWindow:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    // Quit the app automatically after last window is closed.
    return YES;
}

@end
