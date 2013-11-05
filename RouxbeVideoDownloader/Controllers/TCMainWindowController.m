//
//  TCMainWindowController.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMainWindowController.h"

#pragma mark NSString Category

@interface NSString (FindStringAdditions)

- (BOOL)containsString:(NSString *)aString;

@end

@implementation NSString (FindStringAdditions)

- (BOOL)containsString:(NSString *)aString
{
    return NSNotFound != [self rangeOfString:aString].location;
}

@end

#pragma mark -

@interface TCMainWindowController ()

@property (nonatomic, weak) IBOutlet NSTextField *urlTextField;

@end

@implementation TCMainWindowController

- (id)init
{
    self = [super initWithWindowNibName:@"MainWindow" owner:self];
    return self;
}

/**
 * Begins downloading videos from the given URL when user presses the Enter key.
 *
 * @param sender The \c NSTextField that the Enter key was pressed in.
 */
- (IBAction)downloadVideos:(id)sender
{
    // Make sure the action is sent by the URL text field.
    if (sender != self.urlTextField) { return; }

    NSURL *url = [[NSURL alloc] initWithString:self.urlTextField.stringValue];
    NSArray *pathComponents = [url pathComponents];

    // Second last component of the path represents the category.
    NSString *category = pathComponents[pathComponents.count - 2];

    if ([category isEqualToString:@"lessons"]) {

    } else if ([category isEqualToString:@"recipes"]) {

    } else if ([category isEqualToString:@"tips-techniques"]) {
        // Last component of the path represents the content URL itself.
        NSString *contentURL = pathComponents.lastObject;

        // Extract the content's ID from the content URL.
        NSScanner *scanner = [[NSScanner alloc] initWithString:contentURL];
        NSInteger contentID = -1;
        [scanner scanInteger:&contentID];
        NSLog(@"Tip ID: %ld", contentID);

    } else {
        // Error - Invalid URL
    }
}

@end
