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
    self.directoryPopUpButton.directoryURL = self.configuration.downloadsDirectoryURL;
}

#pragma mark - Target-Action

/**
 * This action is sent when the stepper's value has changed.
 *
 * @param sender The \c NSStepper object that send this action.
 */
- (IBAction)stepperValueChanged:(id)sender
{
    if (sender == self.stepper) {
        self.configuration.maxConcurrentDownloadCount = self.stepper.integerValue;
        self.textField.integerValue = self.configuration.maxConcurrentDownloadCount;
    }
}

/**
 * This action method is sent when the pop up button's directory has changed.
 *
 * @param sender The \c TCDirectoryPopUpButton that send this action.
 */
- (IBAction)directoryPopUpButtonDirectoryChanged:(id)sender
{
    if (sender == self.directoryPopUpButton) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        self.configuration.downloadsDirectoryURL = self.directoryPopUpButton.directoryURL;
    }
}

#pragma mark - NSTextField Delegate

/**
 * This notification is sent when the text field's value has changed.
 *
 * @param notification The notification object.
 */
- (void)controlTextDidChange:(NSNotification *)notification
{
    if (notification.object == self.textField) {
        self.configuration.maxConcurrentDownloadCount = self.textField.integerValue;
        self.stepper.integerValue = self.configuration.maxConcurrentDownloadCount;
    }
}

@end
