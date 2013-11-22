//
//  TCDownloadManagerTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadManager.h"
#import "TCDownload.h"

@interface TCDownloadManagerTests : XCTestCase

@end

@implementation TCDownloadManagerTests

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
 * Test that an exception is raised when attepmt to pass in a \c nil URL.
 */
- (void)testRaiseExceptionWhenGivenNilURL
{
    TCDownloadManager *downloadManager = [[TCDownloadManager alloc] init];
    XCTAssertThrows([downloadManager addDownloadsWithURL:nil],
                    @"Should raise exception when given nil URL.");
}

- (void) testCanAddDownloads
{
    TCDownloadManager *downloadManager = [[TCDownloadManager alloc] init];
    [downloadManager addDownloadsWithURL:[NSURL URLWithString:@"http://rouxbe.com"]];

    XCTAssertTrue(3 == downloadManager.downloadQueue.count,
                  @"Should have added the downloads to the queue.");
}

- (void) testDidAddDownloadBlockIsCalled
{
    TCDownloadManager *downloadManager = [[TCDownloadManager alloc] init];
    downloadManager.didAddDownload = ^(TCDownload *download, NSError *error) {
    };

    [downloadManager addDownloadsWithURL:[NSURL URLWithString:@"http://rouxbe.com"]];
}

- (void) testDownloadDidChangeProgressBlockIsCalled
{

}

@end
