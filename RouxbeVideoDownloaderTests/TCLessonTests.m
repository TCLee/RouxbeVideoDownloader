//
//  TCLessonTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCHTTPRequestStub.h"
#import "TCTestDataLoader.h"
#import "TCLesson.h"
#import "TCRouxbeService.h"

@interface TCLessonTests : XCTestCase

@end

@implementation TCLessonTests

- (void)setUp
{
    [super setUp];

    [Expecta setAsynchronousTestTimeout:2.0f];
    [TCHTTPRequestStub beginStubRequests];
}

- (void)tearDown
{
    [super tearDown];

    [Expecta setAsynchronousTestTimeout:1.0f];
    [TCHTTPRequestStub stopStubRequests];
}

#pragma mark -

- (void)testLessonStepsAreFetchedInTheCorrectOrder
{
    __block NSArray *actualPositions = nil;
    __block NSArray *expectedPositions = nil;
    [TCLesson getLessonWithID:101 completeBlock:^(TCGroup *group, NSError *error) {
        actualPositions = [group valueForKeyPath:@"steps.position"];
        expectedPositions = [actualPositions sortedArrayUsingComparator:^NSComparisonResult(NSNumber *position1, NSNumber *position2) {
            return [position1 compare:position2];
        }];
    }];

    expect(actualPositions).willNot.beNil();
    expect(actualPositions).will.equal(expectedPositions);
}

- (void)testShouldCallbackWithErrorIfOneRequestOperationFromBatchFailed
{
    // Stub one of the video URL request to fail.
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"http://rouxbe.com/embedded_player/settings_section/244.xml"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorTimedOut
                                                                      userInfo:nil]];
    }];

    __block TCGroup *blockGroup = nil;
    __block NSError *blockError = nil;
    [TCLesson getLessonWithID:101 completeBlock:^(TCGroup *group, NSError *error) {
        blockGroup = group;
        blockError = error;
    }];

    expect(blockGroup).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorTimedOut);
}

- (void)testShouldCancelRemainingRequestOperationsIfOneRequestOperationFailed
{

}



@end
