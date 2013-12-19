//
//  TCVideoTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCVideo.h"
#import "TCHTTPRequestStub.h"

@interface TCVideoTests : XCTestCase

@property (readwrite, nonatomic, copy) NSURL *dummySourceURL;
@property (readwrite, nonatomic, copy) NSString *dummyGroup;
@property (readwrite, nonatomic, copy) NSString *dummyTitle;

@end

@implementation TCVideoTests

- (void)setUp
{
    [super setUp];

    [TCHTTPRequestStub stubAllRouxbeRequestsToReturnSuccessResponse];

    self.dummySourceURL = [NSURL URLWithString:@"http://media.rouxbe.com/h264/Cs_Eggs_L2_T2.f4v"];
    self.dummyGroup = @"The Video's Group";
    self.dummyTitle = @"Title of Video";
}

- (void)tearDown
{
    [super tearDown];

    [TCHTTPRequestStub stopStubbingRequests];

    self.dummySourceURL = nil;
    self.dummyGroup = nil;
    self.dummyTitle = nil;
}

#pragma mark - Init Method Tests

- (void)testFlashVideoURLShouldBeConvertedToMP4VideoURL
{
    TCVideo *video = [[TCVideo alloc] initWithSourceURL:self.dummySourceURL
                                                  group:self.dummyGroup
                                                  title:self.dummyTitle
                                               position:2];

    expect(video.sourceURL.absoluteString).to.equal(@"http://media.rouxbe.com/itouch/mp4/Cs_Eggs_L2_T2.mp4");
}

- (void)testIndividualVideoShouldHaveNoGroupAndPosition
{
    TCVideo *video = [[TCVideo alloc] initWithSourceURL:self.dummySourceURL
                                                  title:self.dummyTitle];

    expect(video.group).to.beNil();
    expect(video.position).to.equal(NSNotFound);
}

- (void)testShouldRaiseExceptionWhenSourceURLIsNil
{
    void(^blockToTest)() = ^() {
        __unused TCVideo *video =
            [[TCVideo alloc] initWithSourceURL:nil title:self.dummyTitle];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

- (void)testShouldRaiseExceptionWhenTitleIsNil
{
    void(^blockToTest)() = ^() {
        __unused TCVideo *video =
            [[TCVideo alloc] initWithSourceURL:self.dummySourceURL title:nil];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

#pragma mark - Destination Path Component Tests

- (void)testDestinationPathComponentForGroupVideo
{
    TCVideo *video = [[TCVideo alloc] initWithSourceURL:self.dummySourceURL
                                                  group:self.dummyGroup
                                                  title:self.dummyTitle
                                               position:2];

    NSString *expectedPath = [NSString stringWithFormat:@"%@/03 - %@.mp4",
                              self.dummyGroup, self.dummyTitle];
    expect(video.destinationPathComponent).to.equal(expectedPath);
}

- (void)testDestinationPathComponentForIndividualVideo
{
    TCVideo *video = [[TCVideo alloc] initWithSourceURL:self.dummySourceURL
                                                  title:self.dummyTitle];

    NSString *expectedPath = [NSString stringWithFormat:@"%@.mp4", self.dummyTitle];
    expect(video.destinationPathComponent).to.equal(expectedPath);
}

#pragma mark - Get Videos From URL Tests

- (void)testGivenALessonURLShouldReturnLessonVideos
{
    __block TCVideo *blockVideo = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/cooking-school/lessons/241"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideo = videos[1];
    }];

    expect(blockVideo.group).will.equal(@"Eggs | Frying, Basting & Poaching");
    expect(blockVideo.title).will.equal(@"How to Pan Fry Eggs");
    expect(blockVideo.sourceURL).will.equal([NSURL URLWithString:@"http://media.rouxbe.com/itouch/mp4/Cs_Eggs_L2_T2.mp4"]);
    expect(blockVideo.position).will.equal(1);
}

- (void)testGivenARecipeURLShouldReturnRecipeVideos
{
    __block TCVideo *blockVideo = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/recipes/89"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideo = videos[0];
    }];

    expect(blockVideo.group).will.equal(@"Chicken Cashew");
    expect(blockVideo.title).will.equal(@"Making the Sauce");
    expect(blockVideo.sourceURL).will.equal([NSURL URLWithString:@"http://media.rouxbe.com/itouch/mp4/Chicken_Cashew_S1.mp4"]);
    expect(blockVideo.position).will.equal(0);
}

- (void)testGivenATipURLShouldReturnATipVideo
{
    __block NSArray *blockVideos = nil;
    __block TCVideo *blockVideo = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/tips-techniques/117"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockVideo = videos[0];
    }];

    expect(blockVideo.group).will.beNil();
    expect(blockVideo.title).will.equal(@"What is Thai Basil?");
    expect(blockVideo.sourceURL).will.equal([NSURL URLWithString:@"http://media.rouxbe.com/itouch/mp4/DD_ThaiBasil.mp4"]);
    expect(blockVideo.position).will.equal(NSNotFound);

    expect(blockVideos).will.haveCountOf(1);
}

- (void)testFailToFetchLessonVideosShouldCallCompletionBlockWithError
{
    [TCHTTPRequestStub stubLessonRequestToReturnResponseWithError:
     [NSError errorWithDomain:NSURLErrorDomain
                         code:NSURLErrorTimedOut
                     userInfo:nil]];

    __block NSArray *blockVideos = nil;
    __block NSError *blockError = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/cooking-school/lessons/241"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockError = error;
    }];

    expect(blockVideos).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorTimedOut);
}

- (void)testFailToFetchRecipeVideosShouldCallCompletionBlockWithError
{
    [TCHTTPRequestStub stubRecipeRequestToReturnResponseWithError:
     [NSError errorWithDomain:NSURLErrorDomain
                         code:NSURLErrorNotConnectedToInternet
                     userInfo:nil]];

    __block NSArray *blockVideos = nil;
    __block NSError *blockError = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/recipes/89"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockError = error;
    }];

    expect(blockVideos).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorNotConnectedToInternet);
}

- (void)testFailToFetchTipVideoShouldCallCompletionBlockWithError
{
    [TCHTTPRequestStub stubTipRequestToReturnResponseWithError:
     [NSError errorWithDomain:NSURLErrorDomain
                         code:NSURLErrorResourceUnavailable
                     userInfo:nil]];

    __block NSArray *blockVideos = nil;
    __block NSError *blockError = nil;
    [TCVideo getVideosFromURL:[NSURL URLWithString:@"http://rouxbe.com/tips-techniques/117"] completeBlock:^(NSArray *videos, NSError *error) {
        blockVideos = videos;
        blockError = error;
    }];

    expect(blockVideos).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorResourceUnavailable);
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

@end
