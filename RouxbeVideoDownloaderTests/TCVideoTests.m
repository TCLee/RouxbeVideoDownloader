//
//  TCVideoTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCVideo.h"
#import "TCLesson.h"
#import "TCRecipe.h"
#import "TCTip.h"

@interface TCVideoTests : XCTestCase

@end

@implementation TCVideoTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Init Method Tests

- (void)testFlashVideoURLShouldBeConvertedToMP4VideoURL
{
    TCVideo *video = [self groupVideoForTesting];

    expect(video.sourceURL.absoluteString).to.equal(@"http://media.rouxbe.com/itouch/mp4/Cs_Eggs_L2_T2.mp4");
}

- (void)testIndividualVideoShouldHaveNoGroupAndPosition
{
    TCVideo *video = [self individualVideoForTesting];

    expect(video.group).to.beNil();
    expect(video.position).to.equal(NSNotFound);
}

- (void)testShouldRaiseExceptionWhenSourceURLIsNil
{
    void(^blockToTest)() = ^() {
        __unused TCVideo *video =
            [[TCVideo alloc] initWithSourceURL:nil title:[self dummyTitle]];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

- (void)testShouldRaiseExceptionWhenTitleIsNil
{
    void(^blockToTest)() = ^() {
        __unused TCVideo *video =
            [[TCVideo alloc] initWithSourceURL:[self dummySourceURL] title:nil];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

#pragma mark - Destination Path Component Tests

- (void)testDestinationPathComponentForGroupVideo
{
    TCVideo *video = [self groupVideoForTesting];

    NSString *expectedPath = [NSString stringWithFormat:@"%@/03 - %@.mp4",
                              self.dummyGroup, self.dummyTitle];
    expect(video.destinationPathComponent).to.equal(expectedPath);
}

- (void)testDestinationPathComponentForIndividualVideo
{
    TCVideo *video = [self individualVideoForTesting];

    NSString *expectedPath = [NSString stringWithFormat:@"%@.mp4", self.dummyTitle];
    expect(video.destinationPathComponent).to.equal(expectedPath);
}

#pragma mark - Get Videos From URL Tests

- (void)testGivenALessonURLShouldFetchLessonVideos
{
    id lessonMock = [OCMockObject mockForClass:[TCLesson class]];
    [[[[lessonMock expect] ignoringNonObjectArgs] classMethod]
     getLessonWithID:0 completeBlock:OCMOCK_ANY];

    [TCVideo getVideosFromURL:[self lessonURL] completeBlock:nil];

    [lessonMock verify];
    [lessonMock stopMocking];
}

- (void)testGivenARecipeURLShouldFetchRecipeVideos
{
    id recipeMock = [OCMockObject mockForClass:[TCRecipe class]];
    [[[[recipeMock expect] ignoringNonObjectArgs] classMethod]
     getRecipeWithID:0 completeBlock:OCMOCK_ANY];

    [TCVideo getVideosFromURL:[self recipeURL] completeBlock:nil];

    [recipeMock verify];
    [recipeMock stopMocking];
}

- (void)testGivenATipURLShouldFetchTipVideo
{
    id tipMock = [OCMockObject mockForClass:[TCTip class]];
    [[[[tipMock expect] ignoringNonObjectArgs] classMethod]
     getTipWithID:0 completeBlock:OCMOCK_ANY];

    [TCVideo getVideosFromURL:[self tipURL] completeBlock:nil];

    [tipMock verify];
    [tipMock stopMocking];
}

- (void)testFailToFetchLessonVideosShouldCallCompletionBlockWithError
{
    id lessonMock = [OCMockObject mockForClass:[TCLesson class]];
    [[[[lessonMock stub] ignoringNonObjectArgs] andDo:[self stubBlock]]
     getLessonWithID:0 completeBlock:OCMOCK_ANY];

    [self verifyCompletionBlockIsCalledWithErrorForURL:[self lessonURL]];
}

- (void)testFailToFetchRecipeVideosShouldCallCompletionBlockWithError
{
    id recipeMock = [OCMockObject mockForClass:[TCRecipe class]];
    [[[[recipeMock stub] ignoringNonObjectArgs] andDo:[self stubBlock]]
     getRecipeWithID:0 completeBlock:OCMOCK_ANY];

    [self verifyCompletionBlockIsCalledWithErrorForURL:[self recipeURL]];
}

- (void)testFailToFetchTipVideoShouldCallCompletionBlockWithError
{
    id tipMock = [OCMockObject mockForClass:[TCTip class]];
    [[[[tipMock stub] ignoringNonObjectArgs] andDo:[self stubBlock]]
     getTipWithID:0 completeBlock:OCMOCK_ANY];

    [self verifyCompletionBlockIsCalledWithErrorForURL:[self tipURL]];
}

- (void)testGivenAnInvalidURLShouldReturnError
{
    __block NSArray *blockVideos = nil;
    __block NSError *blockError = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://www.google.com"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockError = error;
    }];

    expect(blockVideos).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorUnsupportedURL);
}

- (void)testGivenNilURLShouldRaiseException
{
    void(^blockToTest)() = ^() {
        [TCVideo getVideosFromURL:nil completeBlock:nil];
    };
    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

#pragma mark - Private Methods

- (TCVideo *)groupVideoForTesting
{
    return [[TCVideo alloc] initWithSourceURL:[self dummySourceURL]
                                        group:[self dummyGroup]
                                        title:[self dummyTitle]
                                     position:2];
}

- (TCVideo *)individualVideoForTesting
{
    return [[TCVideo alloc] initWithSourceURL:[self dummySourceURL]
                                        title:[self dummyTitle]];
}

- (NSURL *)dummySourceURL
{
    return [NSURL URLWithString:@"http://media.rouxbe.com/h264/Cs_Eggs_L2_T2.f4v"];
}

- (NSString *)dummyGroup
{
    return @"The Video Group";
}

- (NSString *)dummyTitle
{
    return @"The Video Title";
}

- (NSURL *)lessonURL
{
    return [NSURL URLWithString:@"http://rouxbe.com/cooking-school/lessons/241"];
}

- (NSURL *)recipeURL
{
    return [NSURL URLWithString:@"http://rouxbe.com/recipes/89"];
}

- (NSURL *)tipURL
{
    return [NSURL URLWithString:@"http://rouxbe.com/tips-techniques/117"];
}

- (NSError *)dummyError
{
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:NSURLErrorNotConnectedToInternet
                           userInfo:nil];
}

- (void(^)(NSInvocation *))stubBlock
{
    return ^(NSInvocation *invocation) {
        void(^completeBlock)(id, NSError *) = [invocation getArgumentAtIndexAsObject:3];
        completeBlock(nil, [self dummyError]);
    };
}

- (void)verifyCompletionBlockIsCalledWithErrorForURL:(NSURL *)aURL
{
    __block NSArray *blockVideos = nil;
    __block NSError *blockError = nil;
    [TCVideo getVideosFromURL:aURL completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockError = error;
    }];

    expect(blockVideos).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError).will.equal([self dummyError]);
}

@end
