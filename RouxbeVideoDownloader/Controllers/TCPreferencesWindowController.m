//
//  TCPreferencesWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/11/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCPreferencesWindowController.h"
#import "TCDirectoryPopUpButton.h"
#import "TCDownloadConfiguration.h"

@interface TCPreferencesWindowController ()

@property (readwrite, nonatomic, weak) IBOutlet NSStepper *stepper;
@property (readwrite, nonatomic, weak) IBOutlet NSTextField *maxConcurrentDownloadCountTextField;
@property (readwrite, nonatomic, weak) IBOutlet TCDirectoryPopUpButton *downloadsDirectoryPopUpButton;

@end

@implementation TCPreferencesWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"PreferencesWindow"];
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your
    // window controller's window has been loaded from its nib file.
}

#pragma mark - Target-Action

- (IBAction)stepperValueChanged:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)textFieldEndEditing:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)directoryPopUpButtonDirectoryChanged:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
