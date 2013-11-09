//
//  TCFindStringAdditionsTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "NSString+FindSubstringAdditions.h"

@interface TCFindStringAdditionsTests : XCTestCase

@property (nonatomic, copy) NSString *testString;

@end

@implementation TCFindStringAdditionsTests

- (void)setUp
{
    [super setUp];

    // Use a sample URL's path from Rouxbe for testing.
    self.testString = @"/cooking-school/lessons/579-how-to-stir-fry/details";
}

- (void)tearDown
{
    self.testString = nil;

    [super tearDown];
}

- (void)testSearchWithNoOptions
{
    BOOL result = [self.testString containsString:@"lessons" options:kNilOptions];
    XCTAssert(result, @"The substring 'lessons' should be found in test string.");
}

- (void)testCaseInsensitiveSearch
{
    BOOL result = [self.testString containsString:@"LESSONS" options:NSCaseInsensitiveSearch];
    XCTAssert(result, @"The substring 'LESSONS' should be found in test string.");
}

- (void)testStringNotFound
{
    BOOL result = [self.testString containsString:@"whatever" options:NSCaseInsensitiveSearch];
    XCTAssert(!result, @"The substring 'whatever' should be found in test string.");
}

@end
