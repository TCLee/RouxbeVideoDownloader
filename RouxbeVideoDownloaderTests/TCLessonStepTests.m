//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCMockXMLServiceFactory.h"
#import "TCLessonStep.h"
#import "TCMP4VideoURL.h"

/**
 * @test
 * Tests to verify the interfaces of \c TCLessonStep class.
 */
@interface TCLessonStepTests : XCTestCase

@property (nonatomic, copy) NSString *lessonName;
@property (nonatomic, copy) NSArray *lessonStepsXML;

@end

@implementation TCLessonStepTests

- (void)setUp
{
    [super setUp];

    // Load the test XML data.
    NSError *__autoreleasing error = nil;
    NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
                                              error:&error];
    XCTAssertNotNil(data, @"Failed to load test data. Error: %@", error);

    // Get all the lesson steps from the XML.
    RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
    self.lessonName = [rootXML attribute:@"name"];
    self.lessonStepsXML = [rootXML childrenWithRootXPath:@"/recipe/recipesteps/recipestep"];
}

- (void)tearDown
{
    self.lessonName = nil;
    self.lessonStepsXML = nil;

    [super tearDown];
}

/**
 * Creates a new \c TCLessonStep with properties initialized from the XML.
 *
 * @param index The index of the step to create.
 *
 * @return A new and initialized \c TCLessonStep object.
 */
- (TCLessonStep *)lessonStepWithIndex:(NSUInteger)index
{
    return [[TCLessonStep alloc] initWithXML:self.lessonStepsXML[index]
                                  lessonName:self.lessonName];
}

/**
 * @test
 * Test that we can create a \c TCLessonStep object from the XML data.
 */
- (void)testInitWithXMLData
{
    TCLessonStep *step = [self lessonStepWithIndex:0];

    // Verify that this lesson step is created properly from the XML.
    XCTAssert(step.ID == 105, @"The step ID was not parsed properly from the XML.");
    XCTAssert(step.position == 0, @"The step position was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.lessonName, @"How to Cut Using a Chef's Knife", @"The lesson name was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.name, @"Intro to How to Use a Chef's Knife", @"The step name was not parsed properly from the XML.");
    XCTAssertEqualObjects(step.videoURL, [TCMP4VideoURL MP4VideoURLWithString:@"PB_Chef_Knife_Cut_L3_T1c.f4v"], @"The step video URL was not parsed properly from the XML.");
}

/**
 * @test
 * Test that the lesson step's video player XML URL is the correct format.
 */
- (void) testLessonStepVideoXMLURL
{
    id mock = [TCMockXMLServiceFactory mockXMLServiceWithBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
        XCTAssertEqualObjects(requestURL, [NSURL URLWithString:@"http://rouxbe.com/embedded_player/settings_section/106.xml"],
                              @"Request URL does not match the expected rouxbe.com URL.");
    }];

    TCLessonStep *step = [self lessonStepWithIndex:1];
    [step videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {}];

    [mock stopMocking];
}

/**
 * @test
 * Test fetching a video URL with a success case.
 */
- (void) testFetchVideoURLSuccess
{
    id mock = [TCMockXMLServiceFactory mockXMLServiceWithBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
        NSError *error = nil;
        NSData *data = [TCTestDataLoader XMLDataWithName:@"LessonStepVideo"
                                                   error:&error];
        NSAssert(data, @"%@", [error localizedDescription]);
        
        completionBlock(data, nil);
    }];

    TCLessonStep *step = [self lessonStepWithIndex:1];
    [step videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {
        XCTAssertEqualObjects(videoURL, [TCMP4VideoURL MP4VideoURLWithString:@"CS_Knives_L3_T02.f4v"],
                              @"Returned video URL does not match the expected URL.");
        XCTAssertEqualObjects(videoURL, step.videoURL, @"Lesson step's video URL should be set upon return.");
        XCTAssertNil(error, @"Error object should be nil, on success.");
    }];

    [mock stopMocking];
}

/**
 * @test
 * Test fetching a video URL with an error case.
 */
- (void) testFetchVideoURLError
{
    id mock = [TCMockXMLServiceFactory mockXMLServiceWithBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                    code:NSURLErrorCannotParseResponse
                                                userInfo:nil];
        completionBlock(nil, error);
    }];

    TCLessonStep *step = [self lessonStepWithIndex:1];
    [step videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {
        XCTAssertNil(videoURL, @"Video URL should be nil, on error.");
        XCTAssertNil(step.videoURL, @"Lesson step's video URL should not be set on error.");

        XCTAssertNotNil(error, @"NSError object should have a value, on an error.");
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"NSError object should have the correct error domain.");
        XCTAssertTrue(error.code == NSURLErrorCannotParseResponse, @"NSError object should have the correct error code.");
    }];

    [mock stopMocking];
}

@end
