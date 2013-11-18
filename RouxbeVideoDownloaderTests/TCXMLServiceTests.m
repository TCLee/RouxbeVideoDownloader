//
//  TCXMLServiceTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCXMLService.h"
#import "TCMockAFHTTPSessionManager.h"

@interface TCXMLServiceTests : XCTestCase

@end

@implementation TCXMLServiceTests

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
 * Test that when given a \c nil URL it should raise an exception.
 */
- (void) testRaiseExceptionWhenGivenNilURL
{
    XCTAssertThrows([TCXMLService requestXMLDataWithURL:nil completion:nil],
                    @"Should raise exception when given nil URL.");
}

/**
 * @test
 * Test that the response serializer object is configured to 
 * handle XML responses.
 */
- (void)testResponseSerializerIsConfiguredForXML
{
    id mock = [TCMockAFHTTPSessionManager mockHTTPSessionManagerWithSetResponseSerializerBlock:^(AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer) {
        XCTAssertTrue(responseSerializer.stringEncoding == NSUTF8StringEncoding,
                      @"String encoding should be UTF-8.");

        NSSet *expectedContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
        XCTAssertTrue([responseSerializer.acceptableContentTypes isEqualToSet:expectedContentTypes],
                      @"Acceptable content types should handle XML.");
    }];

    [TCXMLService requestXMLDataWithSessionManager:mock
                                               URL:[NSURL URLWithString:@"http://rouxbe.com"]
                                        completion:nil];
}

/**
 * @test
 * Test receiving a success response.
 */
- (void)testSuccessResponse
{
    id mock = [TCMockAFHTTPSessionManager mockHTTPSessionManagerWithGETBlock:^NSURLSessionDataTask *(NSString *URLString, NSDictionary *parameters, AFHTTPSessionManagerSuccessBlock success, AFHTTPSessionManagerFailureBlock failure) {
        NSData *fakeData = [[NSData alloc] init];
        success(nil, fakeData);
        return nil;
    }];

    NSURL *url = [NSURL URLWithString:@"http://rouxbe.com"];

    [TCXMLService requestXMLDataWithSessionManager:mock URL:url completion:^(NSData *data, NSError *error) {
        XCTAssertNotNil(data, @"Data should NOT be nil on success.");
        XCTAssertNil(error, @"Error object should be nil on success.");
    }];
}

/**
 * @test
 * Test receiving an error response.
 */
- (void)testErrorResponse
{
    id mock = [TCMockAFHTTPSessionManager mockHTTPSessionManagerWithGETBlock:^NSURLSessionDataTask *(NSString *URLString, NSDictionary *parameters, AFHTTPSessionManagerSuccessBlock success, AFHTTPSessionManagerFailureBlock failure) {
        NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                    code:NSURLErrorCannotParseResponse
                                                userInfo:nil];
        failure(nil, error);
        return nil;
    }];

    NSURL *url = [NSURL URLWithString:@"http://rouxbe.com"];

    [TCXMLService requestXMLDataWithSessionManager:mock URL:url completion:^(NSData *data, NSError *error) {
        XCTAssertNil(data, @"Data should be nil on error.");

        XCTAssertNotNil(error, @"Error object should NOT be nil on error.");
        XCTAssertEqualObjects(error.domain, NSURLErrorDomain,
                              @"Error domain should match provided error domain.");
        XCTAssertTrue(error.code == NSURLErrorCannotParseResponse,
                      @"Error code should match provided error code.");
    }];
}

@end
