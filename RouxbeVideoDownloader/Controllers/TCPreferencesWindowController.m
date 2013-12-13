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
@property (readwrite, nonatomic, weak) IBOutlet NSTextField *textField;
@property (readwrite, nonatomic, weak) IBOutlet TCDirectoryPopUpButton *directoryPopUpButton;

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

    // Initialize the view with the configuration model's values.
    self.stepper.integerValue = self.configuration.maxConcurrentDownloadCount;
    self.textField.integerValue = self.configuration.maxConcurrentDownloadCount;
    self.directoryPopUpButton.selectedDirectoryURL = self.configuration.downloadsDirectoryURL;
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
