//
//  TCTipTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTip.h"
#import "TCTestDataLoader.h"

@interface TCTipTests : XCTestCase

@end

@implementation TCTipTests

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

- (void)testCanParseTipFromXMLData
{
    NSData *data = [TCTestDataLoader XMLDataWithName:@"Tip"];
    TCTip *tip = [[TCTip alloc] initWithXMLData:data];

    expect(tip.ID).to.equal(117);
    expect(tip.name).to.equal(@"What is Thai Basil?");
    expect(tip.videoURL).to.equal([NSURL URLWithString:@"http://media.rouxbe.com/h264/DD_ThaiBasil.f4v"]);
}

@end
