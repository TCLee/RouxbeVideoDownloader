//
//  TCStepTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestDataLoader.h"
#import "TCStep.h"

@interface TCStepTests : XCTestCase

@end

@implementation TCStepTests

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

- (void)testCanCreateStepObjectFromXML
{
    NSData *data = [TCTestDataLoader XMLDataWithName:@"Recipe"];
    RXMLElement *rootElement = [[RXMLElement alloc] initFromXMLData:data];
    RXMLElement *recipeStepsElement = [rootElement child:@"recipeSteps"];
    TCStep *step = [[TCStep alloc] initWithXML:[recipeStepsElement children:@"recipeStep"][0]
                                     groupName:@"The Group Name"];

    expect(step.groupName).to.equal(@"The Group Name");
    expect(step.ID).to.equal(193);
    expect(step.position).to.equal(0);
    expect(step.name).to.equal(@"Making the Sauce");
    expect(step.videoURL).to.equal([NSURL URLWithString:@"http://media.rouxbe.com/h264/Chicken_Cashew_S1.f4v"]);
}

@end
