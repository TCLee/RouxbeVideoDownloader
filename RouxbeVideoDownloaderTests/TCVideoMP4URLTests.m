//
//  TCVideoMP4URLTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCVideoMP4URL.h"

@interface TCVideoMP4URLTests : XCTestCase

@end

@implementation TCVideoMP4URLTests

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
 * Test to ensure we can successfully convert a Flash video URL to a MP4 video URL.
 */
- (void)testConvertFlashVideoURLToMP4VideoURL
{
    NSURL *flashVideoURL = [NSURL URLWithString:@"http://media.rouxbe.com/h264/Cs_Eggs_L2_T2.f4v"];
    NSURL *mp4VideoURL = [TCVideoMP4URL mp4VideoURLFromFlashVideoURL:flashVideoURL];

    XCTAssertEqualObjects([mp4VideoURL absoluteString], @"http://media.rouxbe.com/itouch/mp4/Cs_Eggs_L2_T2.mp4", @"Failed to convert Flash video URL to MP4 video URL.");
}

@end
