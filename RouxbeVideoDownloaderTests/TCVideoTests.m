//
//  TCVideoTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCVideo.h"

@interface TCVideoTests : XCTestCase

@property (readwrite, nonatomic, copy) NSURL *dummySourceURL;
@property (readwrite, nonatomic, copy) NSString *dummyGroup;
@property (readwrite, nonatomic, copy) NSString *dummyTitle;

@end

@implementation TCVideoTests

- (void)setUp
{
    [super setUp];

    self.dummySourceURL = [NSURL URLWithString:@"http://media.rouxbe.com/h264/Cs_Eggs_L2_T2.f4v"];
    self.dummyGroup = @"The Video's Group";
    self.dummyTitle = @"Title of Video";
}

- (void)tearDown
{
    self.dummySourceURL = nil;
    self.dummyGroup = nil;
    self.dummyTitle = nil;

    [super tearDown];
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

- (void)testShouldRaiseExceptionWhenSearchURLIsNil
{
    void(^blockToTest)() = ^() {
        [TCVideo getVideosFromURL:nil completeBlock:nil];
    };

    expect(blockToTest).to.raise(NSInternalInconsistencyException);
}

@end
