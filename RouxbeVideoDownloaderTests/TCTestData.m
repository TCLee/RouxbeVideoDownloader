//
//  TCTestData.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCTestData.h"

@implementation TCTestData

+ (NSData *)XMLDataWithName:(NSString *)name
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *xmlURL= [testBundle URLForResource:name withExtension:@"xml"];
    NSAssert(xmlURL, @"The XML file '%@.xml' could not be located.", name);

    NSError *__autoreleasing error = nil;
    NSData *xmlData = [[NSData alloc] initWithContentsOfURL:xmlURL options:kNilOptions error:&error];
    NSAssert(xmlData, @"Failed to load XML data from unit test bundle. Error: %@", [error localizedDescription]);

    return xmlData;
}

@end
