//
//  TCVideoMP4URLTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCMP4VideoURL.h"

/**
 * @test
 * Tests for the utility class \c TCMP4VideoURL.
 */
@interface TCMP4VideoURLTests : XCTestCase

@end

@implementation TCMP4VideoURLTests

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
 * @test
 * Test to ensure we can successfully convert a Flash video URL 
 * to a MP4 video URL.
 */
- (void)testCanConvertFlashVideoURLToMP4VideoURL
{
    NSURL *videoURL = [TCMP4VideoURL MP4VideoURLWithString:@"http://media.rouxbe.com/h264/Cs_Eggs_L2_T2.f4v"];
    
    XCTAssertEqualObjects(videoURL, [NSURL URLWithString:@"http://media.rouxbe.com/itouch/mp4/Cs_Eggs_L2_T2.mp4"],
                          @"Should be able to return a MP4 video URL.");
}

/**
 * @test
 * Test that if given a \c nil URL string, it will return \c nil.
 */
- (void)testReturnNilWhenGivenNil
{
    NSURL *videoURL = [TCMP4VideoURL MP4VideoURLWithString:nil];

    XCTAssertNil(videoURL, @"Should be nil, given a nil URL string.");
}

@end
