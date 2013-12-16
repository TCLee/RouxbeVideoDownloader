//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCStep+Lesson.h"

@interface TCLessonStepTests : XCTestCase

@property (readwrite, nonatomic, strong) AFHTTPRequestOperation *actualOperation;
@property (readwrite, nonatomic, strong) id mockOperation;

@property (readwrite, nonatomic, strong) NSURL *blockVideoURL;
@property (readwrite, nonatomic, strong) NSError *blockError;

@end

@implementation TCLessonStepTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    TCStep *step = [[TCStep alloc] init];

    // Save the video URL and error values from the completion block.
    self.actualOperation = [step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
        self.blockVideoURL = videoURL;
        self.blockError = error;
    }];

    // Create a mock of AFHTTPRequestOperation, so that we don't actually hit
    // the network when the start method is called.
    self.mockOperation = [OCMockObject partialMockForObject:self.actualOperation];
    [[[self.mockOperation stub] andDo:^(NSInvocation *invocation) {
        [self.mockOperation completionBlock]();
    }] start];
}

- (void)tearDown
{
    [self.mockOperation stopMocking];
    self.mockOperation = nil;

    self.actualOperation = nil;
    self.blockVideoURL = nil;
    self.blockError = nil;

    [super tearDown];
}

- (void)testCanParseVideoURLFromXMLData
{
    [[[self.mockOperation stub]
      andReturn:[TCTestDataLoader XMLDataWithName:@"LessonStepVideo"]]
     responseObject];

    [self.actualOperation start];

    expect(self.blockVideoURL).will.equal([NSURL URLWithString:@"http://media.rouxbe.com/h264/CS_Knives_L3_T02.f4v"]);
    expect(self.blockError).will.beNil();
}

- (void)testErrorIsSetOnFailure
{
    NSError *dummyError = [NSError errorWithDomain:NSURLErrorDomain
                                              code:NSURLErrorTimedOut
                                          userInfo:nil];
    [[[self.mockOperation stub] andReturn:dummyError] error];

    [self.actualOperation start];

    expect(self.blockVideoURL).will.beNil();
    expect(self.blockError).willNot.beNil();
    expect(self.blockError.code).will.equal(NSURLErrorTimedOut);
}

@end
