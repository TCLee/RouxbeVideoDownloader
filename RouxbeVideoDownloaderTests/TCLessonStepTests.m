//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCLessonStep.h"

/**
 * @test
 * Tests to verify the interfaces of \c TCLessonStep class.
 */
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

/**
 * @test
 * Test that we can create a \c TCLessonStep object from the XML data.
 */
- (void)testInitWithXMLData
{
    // Load the test XML data.
    NSError *__autoreleasing error = nil;
    NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
                                              error:&error];
    XCTAssertNotNil(data, @"Failed to load test data. Error: %@", error);

    // Extract one lesson step from the XML.
    RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
    NSArray *stepsXML = [rootXML childrenWithRootXPath:@"/recipe/recipesteps/recipestep"];
    TCLessonStep *step = [[TCLessonStep alloc] initWithXML:stepsXML[0] lessonName:[rootXML attribute:@"name"]];

    // Verify that this lesson step is created properly from the XML.
    XCTAssert(step.ID == 105, @"The step ID was not parsed properly from the XML.");
    XCTAssert(step.position == 0, @"The step position was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.lessonName, @"How to Cut Using a Chef's Knife", @"The lesson name was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.name, @"Intro to How to Use a Chef's Knife", @"The step name was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.videoURL, [NSURL URLWithString:@"http://media.rouxbe.com/itouch/mp4/PB_Chef_Knife_Cut_L3_T1c.mp4"], @"The step video URL was not parsed properly from the XML.");
}

@end
