//
//  TCTipTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTip.h"

@interface TCTipTests : XCTestCase

@property (readwrite, nonatomic, assign) NSUInteger expectedTipID;
@property (readwrite, nonatomic, copy) OHHTTPStubsTestBlock stubTestBlock;

@end

@implementation TCTipTests

- (void)setUp
{
    [super setUp];

    self.expectedTipID = 117;

    self.stubTestBlock = ^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"http://rouxbe.com/embedded_player/settings_drilldown/117.xml"];
    };
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    self.expectedTipID = NSNotFound;
    self.stubTestBlock = nil;

    [super tearDown];
}

- (void)testFetchTipWithSuccessShouldCallCompletionBlockWithTipResult
{
    [OHHTTPStubs stubRequestsPassingTest:self.stubTestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"TipVideo.xml", nil)
                                                statusCode:200
                                                   headers:nil];
    }];

    __block TCTip *blockTip = nil;
    __block NSError *blockError = nil;
    [TCTip getTipWithID:self.expectedTipID completeBlock:^(TCTip *tip, NSError *error) {
        blockTip = tip;
        blockError = error;
    }];

    expect(blockError).will.beNil();
    expect(blockTip).willNot.beNil();

    expect(blockTip.ID).will.equal(self.expectedTipID);
    expect(blockTip.name).will.equal(@"What is Thai Basil?");
    expect(blockTip.videoURL).will.equal([NSURL URLWithString:@"http://media.rouxbe.com/h264/DD_ThaiBasil.f4v"]);
}

- (void)testFetchTipWithFailureShouldCallCompletionBlockWithError
{
    [OHHTTPStubs stubRequestsPassingTest:self.stubTestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorTimedOut
                                                                      userInfo:nil]];
    }];

    __block TCTip *blockTip = nil;
    __block NSError *blockError = nil;
    [TCTip getTipWithID:self.expectedTipID completeBlock:^(TCTip *tip, NSError *error) {
        blockTip = tip;
        blockError = error;
    }];

    expect(blockTip).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).to.equal(NSURLErrorTimedOut);
}

@end
