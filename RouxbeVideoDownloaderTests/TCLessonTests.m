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
#import "TCTestData.h"

@interface TCLessonTests : XCTestCase

@end

@implementation TCLessonTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

/**
 * Test initializing a \c TCLesson object from the prepared XML data.
 */
- (void)testInitWithXML
{
    RXMLElement *rootElement = [[RXMLElement alloc] initFromXMLData:[TCTestData XMLDataWithName:@"Lesson"]];
    TCLesson *lesson = [[TCLesson alloc] initWithXMLElement:rootElement];

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
