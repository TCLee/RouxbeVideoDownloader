//
//  TCRouxbeServiceTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCRouxbeService.h"

@interface TCRouxbeServiceTests : XCTestCase

@end

@implementation TCRouxbeServiceTests

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

- (void)testBaseURLPointsToCorrectURL
{
    TCRouxbeService *service = [TCRouxbeService sharedService];

    expect(service.baseURL.absoluteString).to.equal(@"http://rouxbe.com/");
}

- (void)testResponseSerializerIsConfiguredToHandleXMLData
{
    TCRouxbeService *service = [TCRouxbeService sharedService];

    AFHTTPResponseSerializer *responseSerializer = service.responseSerializer;
    expect(responseSerializer.stringEncoding).to.equal(NSUTF8StringEncoding);
    expect(responseSerializer.acceptableContentTypes).to.beSupersetOf([NSSet setWithObjects:@"application/xml", @"text/xml", nil]);
}

@end
