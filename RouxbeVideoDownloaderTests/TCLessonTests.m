//
//  TCLessonTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCLesson.h"
#import "TCLessonStep.h"

@interface TCLessonTests : XCTestCase

@property (nonatomic, copy) NSData *xmlData;

@end

@implementation TCLessonTests

- (void)setUp
{
    [super setUp];

    // Load the Lesson XML data from the unit test bundle.
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *xmlURL= [testBundle URLForResource:@"Lesson" withExtension:@"xml"];

    NSError *__autoreleasing error = nil;
    self.xmlData = [[NSData alloc] initWithContentsOfURL:xmlURL options:kNilOptions error:&error];
    if (nil == self.xmlData) {
        XCTFail(@"Failed to load Lesson XML data from unit test bundle.\nError: %@", [error localizedDescription]);
    }
}

- (void)tearDown
{
    self.xmlData = nil;

    [super tearDown];
}

/**
 * Test initializing a \c TCLesson object from the prepared XML data.
 */
- (void)testInitWithXML
{
    TCLesson *lesson = [[TCLesson alloc] initWithXMLData:self.xmlData];

    XCTAssertNotNil(lesson, @"Lesson object should not be nil, given a valid XML data.");

    XCTAssert(lesson.ID == 104, @"Lesson ID was not parsed properly from the XML.");
    XCTAssertEqualObjects(lesson.name, @"How to Cut Using a Chef's Knife", @"Lesson name was not parsed properly from the XML.");

    XCTAssertNotNil(lesson.steps, @"Lesson should have an array of steps.");
    XCTAssert(lesson.steps.count == 9, @"There should be exactly 9 steps in this lesson.");
    [lesson.steps enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        XCTAssert([object isMemberOfClass:[TCLessonStep class]], @"The lesson's steps array should only contain TCLessonStep objects.");
    }];
}

@end
