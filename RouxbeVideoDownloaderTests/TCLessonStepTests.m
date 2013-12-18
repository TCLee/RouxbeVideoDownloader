//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCGroup.h"
#import "TCStep+Lesson.h"

@interface TCLessonStepTests : XCTestCase

@property (readwrite, nonatomic, strong) TCGroup *group;
@property (readwrite, nonatomic, strong) TCStep *step;

@end

@implementation TCLessonStepTests

- (void)setUp
{
    [super setUp];

    self.group = [[TCGroup alloc] initWithXMLData:[TCTestDataLoader XMLDataWithName:@"Lesson"]
                                     stepsXMLPath:@"recipesteps.recipestep"];
    
    // Pick a step without a video URL.
    self.step = self.group.steps[1];
}

- (void)tearDown
{
    [super tearDown];

    [OHHTTPStubs removeAllStubs];
    self.group = nil;
    self.step = nil;
}

- (void)testCanParseVideoURLFromXML
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"rouxbe.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"LessonStepVideo.xml", nil)
                                                statusCode:200
                                                   headers:@{@"Content-Type":@"application/xml"}];
    }];

    __block NSURL *blockVideoURL = nil;
    __block NSError *blockError = nil;
    AFHTTPRequestOperation *requestOperation = [self.step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
        blockVideoURL = videoURL;
        blockError = error;
    }];
    [requestOperation start];

    expect(blockVideoURL).willNot.beNil();
    expect(blockError).will.beNil();
    expect(self.step.videoURL).will.equal(blockVideoURL);
}

- (void)testErrorIsSetOnFailure
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"rouxbe.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError: [NSError errorWithDomain:NSURLErrorDomain
                                                                           code:NSURLErrorNotConnectedToInternet
                                                                       userInfo:nil]];
    }];

    __block NSURL *blockVideoURL = nil;
    __block NSError *blockError = nil;
    AFHTTPRequestOperation *requestOperation = [self.step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
        blockVideoURL = videoURL;
        blockError = error;
    }];
    [requestOperation start];

    expect(blockVideoURL).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorNotConnectedToInternet);
}

@end
