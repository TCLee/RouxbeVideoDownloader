//
//  TCLessonTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCLesson.h"

@interface TCLessonTests : XCTestCase

@property (readwrite, nonatomic, assign) NSUInteger lessonID;
@property (readwrite, nonatomic, copy) OHHTTPStubsTestBlock stubRequestTestBlock;

@end

@implementation TCLessonTests

- (void)setUp
{
    [super setUp];

    self.lessonID = 240;

    self.stubRequestTestBlock = ^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"http://rouxbe.com/cooking-school/lessons/240.xml"];
    };

    // Stub requests for Lesson URL to return success response.
    [OHHTTPStubs stubRequestsPassingTest:self.stubRequestTestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"Lesson.xml", nil)
                                                statusCode:200
                                                   headers:nil];
    }];

    // Stub requests for Lesson Step video URL to return success response.
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString hasPrefix:@"http://rouxbe.com/embedded_player/settings_section/"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"LessonStepVideo.xml", nil)
                                                statusCode:200
                                                   headers:nil];
    }];
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    self.lessonID = NSNotFound;
    self.stubRequestTestBlock = nil;

    [super tearDown];
}

#pragma mark -

- (void)testLessonStepsAreFetchedInTheCorrectOrder
{
    __block NSArray *actualPositions = nil;
    __block NSArray *expectedPositions = nil;
    [TCLesson getLessonWithID:self.lessonID completeBlock:^(TCGroup *group, NSError *error) {
        actualPositions = [group valueForKeyPath:@"steps.position"];
        expectedPositions = [actualPositions sortedArrayUsingComparator:^NSComparisonResult(NSNumber *position1, NSNumber *position2) {
            return [position1 compare:position2];
        }];
    }];

    expect(actualPositions).willNot.beNil();
    expect(actualPositions).will.equal(expectedPositions);
}

- (void)testFailToFetchOneLessonStepVideoURLShouldCallCompletionBlockWithError
{
    // Stub only one of the Lesson Step video URL request to fail.
    // The other requests should succeed as usual.
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"http://rouxbe.com/embedded_player/settings_section/244.xml"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorNotConnectedToInternet
                                                                      userInfo:nil]];
    }];

    [self verifyErrorWithCode:NSURLErrorNotConnectedToInternet];
}

- (void)testFailToFetchLessonShouldCallCompletionBlockWithError
{
    [OHHTTPStubs stubRequestsPassingTest:self.stubRequestTestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorTimedOut
                                                                      userInfo:nil]];
    }];

    [self verifyErrorWithCode:NSURLErrorTimedOut];
}

- (void)verifyErrorWithCode:(NSInteger)errorCode
{
    __block TCGroup *blockGroup = nil;
    __block NSError *blockError = nil;
    [TCLesson getLessonWithID:self.lessonID completeBlock:^(TCGroup *group, NSError *error) {
        blockGroup = group;
        blockError = error;
    }];

    expect(blockGroup).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(errorCode);
}

@end
