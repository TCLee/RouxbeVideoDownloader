//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestData.h"
#import "TCLessonStep.h"

@interface TCLessonStepTests : XCTestCase

@end

@implementation TCLessonStepTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithXML
{
    RXMLElement *lessonElement = [[RXMLElement alloc] initFromXMLData:[TCTestData XMLDataWithName:@"Lesson"]];

    NSArray *stepElements = [lessonElement childrenWithRootXPath:@"/recipe/recipesteps/recipestep"];
    TCLessonStep *step = [[TCLessonStep alloc]initWithXMLElement:stepElements[0]];

    XCTAssert(step.ID == 105, @"The step ID was not parsed properly from the XML.");
    XCTAssert(step.position == 0, @"The step position was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.name, @"Intro to How to Use a Chef's Knife", @"The step name was not parsed properly from the XML.");
}

@end
