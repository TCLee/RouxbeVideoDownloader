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
#import "TCTestDataLoader.h"

/**
 * @test
 * Tests to verify the interface of the \c TCLesson class.
 */
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
 * @test
 * Test initializing a \c TCLesson object from the prepared XML data.
 */
- (void)testInitWithXMLData
{
    // Load the test XML data.
    NSError *__autoreleasing error = nil;
    NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
                                              error:&error];
    XCTAssertNotNil(data, @"Failed to load test data. Error: %@", error);

    TCLesson *lesson = [[TCLesson alloc] initWithXMLData:data];

    // Verify that a Lesson can be parsed from the XML.
    XCTAssertNotNil(lesson, @"Lesson should be a valid object given a proper XML.");
    XCTAssert(lesson.ID == 104, @"Lesson ID was not parsed properly from the XML.");
    XCTAssertEqualObjects(lesson.name, @"How to Cut Using a Chef's Knife", @"Lesson name was not parsed properly from the XML.");

    // Verify that a Lesson's step can also be parsed from the XML.
    XCTAssertNotNil(lesson.steps, @"Lesson should have an array of steps.");
    XCTAssert(lesson.steps.count == 9, @"The number of steps in this lesson is wrong.");
    [lesson.steps enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        XCTAssert([object isMemberOfClass:[TCLessonStep class]], @"The lesson's steps array should only contain TCLessonStep objects.");
    }];
}

- (void)testFetchLessonWithSuccess
{

}

- (void)testFetchLessonWithFailure
{

}

///**
// * @test
// * Test that the Lesson request URL is the correct format.
// */
//- (void)testLessonXMLURL
//{
//    id mock = [TCMockXMLService mockXMLServiceWithRequestXMLBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
//        XCTAssertEqualObjects(requestURL, [NSURL URLWithString:@"http://rouxbe.com/cooking-school/lessons/101.xml"],
//                              @"Lesson request URL should match the expected rouxbe.com URL.");
//    }];
//
//    [TCLesson lessonWithID:101 completionHandler:^(TCLesson *lesson, NSError *error) {
//    }];
//
//    [mock stopMocking];
//}
//
///**
// * @test
// * Test fetching a Lesson object with a success case.
// */
//- (void) testFetchLessonSuccess
//{
//    id mock = [TCMockXMLService mockXMLServiceWithRequestXMLBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
//        // Load the XML data from the test bundle.
//        NSError *__autoreleasing error = nil;
//        NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
//                                                  error:&error];
//        NSAssert(data, @"%@", error.localizedDescription);
//        
//        completionBlock(data, nil);
//    }];
//
//    [TCLesson lessonWithID:101 completionHandler:^(TCLesson *lesson, NSError *error) {
//        XCTAssertNotNil(lesson, @"The lesson object should have a value on success.");
//        XCTAssertNil(error, @"The error object should be nil on error.");
//    }];
//
//    [mock stopMocking];
//}
//
///**
// * @test
// * Test fetching a Lesson object with an error.
// */
//- (void) testFetchLessonError
//{
//    id mock = [TCMockXMLService mockXMLServiceWithRequestXMLBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
//        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
//                                                    code:NSURLErrorBadServerResponse
//                                                userInfo:nil];
//        completionBlock(nil, error);
//    }];
//
//    [TCLesson lessonWithID:101 completionHandler:^(TCLesson *lesson, NSError *error) {
//        XCTAssertNil(lesson, @"The lesson object should be nil on error.");
//
//        XCTAssertNotNil(error, @"The error object should have a value on error.");
//        XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"Error object should have the correct domain.");
//        XCTAssertTrue(error.code == NSURLErrorBadServerResponse, @"Error object should have the correct error code.");
//    }];
//
//    [mock stopMocking];
//}

@end
