//
//  TCGroupTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/15/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCGroup.h"
#import "TCStep.h"
#import "TCTestDataLoader.h"

@interface TCGroupTests : XCTestCase

@end

@implementation TCGroupTests

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

- (void)testCanCreateGroupFromXML
{
    NSData *data = [TCTestDataLoader XMLDataWithName:@"Recipe"];
    TCGroup *group = [[TCGroup alloc] initWithXMLData:data
                                         stepsXMLPath:@"recipeSteps.recipeStep"];

    expect(group.ID).to.equal(89);
    expect(group.name).to.equal(@"Chicken Cashew");

    expect(group.steps).to.haveCountOf(3);
    [group.steps enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
        expect(object).to.beInstanceOf([TCStep class]);
    }];
}

@end
