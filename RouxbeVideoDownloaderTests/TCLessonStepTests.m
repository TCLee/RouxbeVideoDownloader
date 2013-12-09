//
//  TCLessonStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCLessonStep.h"
#import "TCRouxbeService.h"
#import "TCTestDataLoader.h"

typedef void (^AFHTTPRequestOperationSuccessBlock)(AFHTTPRequestOperation *operation, NSData *data);
typedef void (^AFHTTPRequestOperationFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

@interface TCLessonStepTests : XCTestCase

@property (nonatomic, copy) NSString *lessonName;
@property (nonatomic, copy) NSArray *lessonStepsXML;

@end

@implementation TCLessonStepTests

- (void)setUp
{
    [super setUp];

    // Load the test XML data.
    NSError *__autoreleasing error = nil;
    NSData *data= [TCTestDataLoader XMLDataWithName:@"Lesson"
                                              error:&error];
    XCTAssertNotNil(data, @"Failed to load test data. Error: %@", error);

    // Get all the lesson steps from the XML.
    RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
    self.lessonName = [rootXML attribute:@"name"];
    self.lessonStepsXML = [rootXML childrenWithRootXPath:@"/recipe/recipesteps/recipestep"];
}

- (void)tearDown
{
    self.lessonName = nil;
    self.lessonStepsXML = nil;

    [super tearDown];
}

/**
 * Creates a new \c TCLessonStep with properties initialized from the XML.
 *
 * @param index The index of the step to create.
 *
 * @return A new and initialized \c TCLessonStep object.
 */
- (TCLessonStep *)lessonStepWithIndex:(NSUInteger)index
{
    return [[TCLessonStep alloc] initWithXML:self.lessonStepsXML[index]
                                  lessonName:self.lessonName];
}

- (void)testCreateLessonStepFromXMLData
{
    TCLessonStep *step = [self lessonStepWithIndex:0];

    expect(step.ID).to.equal(105);
    expect(step.position).to.equal(0);
    expect(step.lessonName).to.equal(@"How to Cut Using a Chef's Knife");
    expect(step.name).to.equal(@"Intro to How to Use a Chef's Knife");
    expect(step.videoURL.absoluteString).to.equal(@"http://media.rouxbe.com/h264/PB_Chef_Knife_Cut_L3_T1c.f4v");
}

- (void)testEmbeddedVideoXMLURLFormatIsCorrect
{
    TCLessonStep *step = [self lessonStepWithIndex:1];
    AFHTTPRequestOperation *requestOperation = [step videoURLRequestOperationWithCompleteBlock:nil];

    expect(requestOperation.request.URL.absoluteString).to.equal(@"http://rouxbe.com/embedded_player/settings_section/106.xml");
}

- (void)testCompletionBlockOnSuccess
{
    id mockService = [OCMockObject niceMockForClass:[TCRouxbeService class]];
    [[[mockService stub] andReturn:mockService] sharedService];

    [[[mockService stub] andDo:^(NSInvocation *invocation) {
        AFHTTPRequestOperationSuccessBlock successBlock = [invocation getArgumentAtIndexAsObject:3];
        successBlock(nil, [TCTestDataLoader XMLDataWithName:@"LessonStepVideo" error:nil]);
    }] HTTPRequestOperationWithRequest:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

    TCLessonStep *step = [self lessonStepWithIndex:1];
    [step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
        expect(error).to.beNil();
        expect(step.videoURL).to.equal(videoURL);
        expect(videoURL.absoluteString).to.equal(@"http://media.rouxbe.com/h264/CS_Knives_L3_T02.f4v");
    }];

    [mockService stopMocking];
}

- (void)testCompletionBlockOnFailure
{
    id mockService = [OCMockObject niceMockForClass:[TCRouxbeService class]];
    [[[mockService stub] andReturn:mockService] sharedService];

    [[[mockService stub] andDo:^(NSInvocation *invocation) {
        AFHTTPRequestOperationFailureBlock failureBlock = [invocation getArgumentAtIndexAsObject:4];
        failureBlock(nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:nil]);
    }] HTTPRequestOperationWithRequest:OCMOCK_ANY success:OCMOCK_ANY failure:OCMOCK_ANY];

    TCLessonStep *step = [self lessonStepWithIndex:1];
    [step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
        expect(videoURL).to.beNil();
        expect(error).notTo.beNil();
    }];

    [mockService stopMocking];
}

@end
