//
//  TCDownloadOperationQueueTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCDownloadOperationQueue.h"
#import "TCDownloadOperation.h"

@interface TCDownloadOperationQueueTests : XCTestCase

@property (nonatomic, strong) TCDownloadOperationQueue *queue;

@end

@implementation TCDownloadOperationQueueTests

- (void)setUp
{
    [super setUp];

    self.queue = [[TCDownloadOperationQueue alloc] initWithMaxConcurrentDownloadCount:5];
}

- (void)tearDown
{
    self.queue = nil;

    [super tearDown];
}

- (void)testAddNilDownloadOperationShouldRaiseException
{
    XCTAssertThrows([self.queue addDownloadOperation:nil],
                    @"Should have raised an exception.");
}

- (void)testAddDownloadOperationShouldStartImmediatelyWhenThereIsAvailableSlots
{
    id mock = [OCMockObject niceMockForClass:[TCDownloadOperation class]];
    [[[mock stub] andReturnValue:@(YES)] isReady];
    [[mock expect] start];

    [self.queue addDownloadOperation:mock];
    [mock verify];
}

@end
