//
//  TCLessonTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCRouxbeServiceStub.h"
#import "TCLesson.h"

@interface TCLessonTests : XCTestCase

@end

@implementation TCLessonTests

- (void)setUp
{
    [super setUp];

    [TCRouxbeServiceStub stubAllRequestsToReturnSuccessResponse];
}

- (void)tearDown
{
    [super tearDown];

    [TCRouxbeServiceStub stopStubbingRequests];
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

- (void)testFailToFetchLessonStepVideoURLShouldCallCompletionBlockWithError
{
    [TCRouxbeServiceStub stubLessonStepVideoRequestToReturnResponseWithError:
     [NSError errorWithDomain:NSURLErrorDomain
                         code:NSURLErrorTimedOut
                     userInfo:nil]];

    [self verifyErrorWithCode:NSURLErrorTimedOut];
}

- (void)testFailToFetchLessonShouldCallCompletionBlockWithError
{
    [TCRouxbeServiceStub stubLessonRequestToReturnResponseWithError:
     [NSError errorWithDomain:NSURLErrorDomain
                         code:NSURLErrorNotConnectedToInternet
                     userInfo:nil]];

    [self verifyErrorWithCode:NSURLErrorNotConnectedToInternet];
}

- (void)verifyErrorWithCode:(NSInteger)errorCode
{
    __block TCGroup *blockGroup = nil;
    __block NSError *blockError = nil;
    [TCLesson getLessonWithID:101 completeBlock:^(TCGroup *group, NSError *error) {
        blockGroup = group;
        blockError = error;
    }];

    expect(blockGroup).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(errorCode);
}

@end
