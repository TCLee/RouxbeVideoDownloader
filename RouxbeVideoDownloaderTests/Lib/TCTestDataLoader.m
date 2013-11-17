//
//  TCTestDataLoader.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCTestDataLoader.h"

@implementation TCTestDataLoader

+ (NSData *)XMLDataWithName:(NSString *)name error:(NSError *__autoreleasing *)outError
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *fileURL= [testBundle URLForResource:name withExtension:@"xml"];

    // Error - Could not locate file in test bundle.
    if (!fileURL) {
        if (outError) {
            *outError = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                                   code:NSFileNoSuchFileError
                                               userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"The XML file '%@.xml' could not be located.", name]}];
        }
        return nil;
    }

    NSError *__autoreleasing readFileError = nil;
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:fileURL options:kNilOptions error:&readFileError];

    // Error - Failed to read contents from file.
    if (!xmlData) {
        if (outError) {
            *outError = [readFileError copy];
        }
        return nil;
    }

    // Success reading XML data.
    return xmlData;
}

@end
