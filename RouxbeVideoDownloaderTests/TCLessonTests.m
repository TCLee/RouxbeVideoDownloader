//
//  TCLessonTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCLesson.h"
#import "TCRouxbeService.h"

typedef void(^AFHTTPRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation, id responseObject);

@interface TCLessonTests : XCTestCase

@end

@implementation TCLessonTests

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

- (id)mockAFHTTPRequestOperation
{
    id mockOperation = [OCMockObject niceMockForClass:[AFHTTPRequestOperation class]];

    void(^theBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        [mockOperation completionBlock]();
    };
    [[[mockOperation stub] andDo:theBlock] start];

    return mockOperation;
}

- (id)mockService
{
    id mockService = [OCMockObject niceMockForClass:[TCRouxbeService class]];
    [[[mockService stub] andReturn:mockService] sharedService];

    void(^theBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSData *data = [TCTestDataLoader XMLDataWithName:@"Lesson"];

        AFHTTPRequestOperation *operation = nil;
        [invocation getReturnValue:&operation];

        AFHTTPRequestOperationSuccessBlock successBlock = [invocation getArgumentAtIndexAsObject:4];
        successBlock(operation, data);
    };
    [[[mockService stub] andDo:theBlock]
     GET:OCMOCK_ANY parameters:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

    [[[mockService stub] andReturn:[self mockAFHTTPRequestOperation]]
     HTTPRequestOperationWithRequest:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

    return mockService;
}

- (void)testLessonStepsAreFetchedInTheCorrectOrder
{
    id mockService = [self mockService];

    [TCLesson getLessonWithID:101 completeBlock:^(TCGroup *group, NSError *error) {
        NSArray *positions = [group.steps valueForKeyPath:@"position"];
        expect(positions).to.equal(@[@0, @1, @2]);
    }];

    [mockService stopMocking];
}

@end
