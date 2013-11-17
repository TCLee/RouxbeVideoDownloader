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
#import "TCXMLService.h"

/**
 * The block signature used to mock
 * TCXMLService::requestXMLDataWithURL:completion: class method.
 *
 * @param requestURL      The request URL passed into the mock method.
 * @param completionBlock The completion block to call before the 
 *                        mock method returns.
 */
typedef void(^TCMockXMLServiceBlock)(NSURL *requestURL, TCXMLServiceBlock completionBlock);

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

/**
 * @test
 * Test fetching a Lesson object with a success case.
 */
- (void) testFetchLessonSuccess
{
    id mock = [self mockXMLServiceWithBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
        // Verify that we've received the correct Lesson XML URL.
        XCTAssertEqualObjects(requestURL, [NSURL URLWithString:@"http://rouxbe.com/cooking-school/lessons/101.xml"], @"Request URL does not match the expected URL.");

        // Load the XML data from the test bundle.
        NSError *__autoreleasing error = nil;
        NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
                                                  error:&error];
        completionBlock(data, error);
    }];

    [TCLesson lessonWithID:101 completionHandler:^(TCLesson *lesson, NSError *error) {
        XCTAssertNotNil(lesson, @"The lesson object should have a value on success.");
        XCTAssertNil(error, @"The error object should be nil on error.");
    }];

    [mock stopMocking];
}

/**
 * @test
 * Test fetching a Lesson object with a fail case.
 */
- (void) testFetchLessonError
{
    // A mock service that always return a failed response.
    id mock = [self mockXMLServiceWithBlock:^(NSURL *requestURL, TCXMLServiceBlock completionBlock) {
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                    code:NSURLErrorBadServerResponse
                                                userInfo:nil];
        completionBlock(nil, error);
    }];

    [TCLesson lessonWithID:101 completionHandler:^(TCLesson *lesson, NSError *error) {
        XCTAssertNil(lesson, @"The lesson object should be nil on error.");
        XCTAssertNotNil(error, @"The error object should have a value on error.");

        // Verify that the error object gets propagated from the XML Service
        // class back to the caller.
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain, @"The error object does not match the one created by TCXMLService class.");
        XCTAssertTrue(error.code == NSURLErrorBadServerResponse, @"The error object does not match the one created by TCXMLService class.");
    }];

    [mock stopMocking];
}

/**
 * Creates and returns a mock of \c TCXMLService class with its method 
 * \c requestXMLDataWithURL:completion: replaced with \c aBlock.
 *
 * @param aBlock The block to replace the method with.
 *
 * @return A mock of \c TCXMLService class.
 */
- (id)mockXMLServiceWithBlock:(TCMockXMLServiceBlock)mockBlock
{
    id mock = [OCMockObject mockForClass:[TCXMLService class]];

    void(^invocationBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSURL *requestURL = [[invocation getArgumentAtIndexAsObject:2] copy];
        TCXMLServiceBlock completionBlock = [[invocation getArgumentAtIndexAsObject:3] copy];
        mockBlock(requestURL, completionBlock);
    };
    
    [[[[mock stub] classMethod] andDo:invocationBlock]
     requestXMLDataWithURL:OCMOCK_ANY completion:OCMOCK_ANY];

    return mock;
}

@end
