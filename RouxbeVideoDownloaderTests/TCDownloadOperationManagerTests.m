//
//  TCDownloadOperationManagerTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadOperationManager.h"
#import "TCDownloadConfiguration.h"
#import "TCDownloadOperation.h"

@interface TCDownloadOperationManagerTests : XCTestCase

@end

@implementation TCDownloadOperationManagerTests

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

- (void)testThatOnlyCompletedDownloadsAreRemoved
{
    // Add an executing download operation to the queue.
    // Add a cancelled download operation to the queue.
    // Add a failed download operation to the queue.
    // Add a completed download operation to the queue.
    // Remove only finished download operations from queue.

    // Verify that only the finished download operation has been removed from the queue.
}

@end
