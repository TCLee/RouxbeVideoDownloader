//
//  TCRouxbeURLValidationTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "NSURL+RouxbeAdditions.h"

/**
 * This test class contains tests for the validation of a Rouxbe URL.
 */
@interface TCRouxbeURLValidationTests : XCTestCase

@end

@implementation TCRouxbeURLValidationTests

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

#pragma mark - Test Valid URLs

/**
 * Test that a valid Rouxbe Lesson URL should return YES when validating.
 */
- (void)testValidLessonURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Lesson URL.");
}

/**
 * Test that a valid Rouxbe Tip URL should return YES when validating.
 */
- (void)testValidTipURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/60-why-meat-needs-to-rest-after-cooking"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Tips & Techniques URL.");
}

/**
 * Test that a valid Rouxbe Recipe URL should return YES when validating.
 */
- (void)testValidRecipeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Recipe URL.");
}

#pragma mark - Test Invalid URLs

/**
 * Test that a URL with the wrong host should return NO when validating.
 */
- (void)testInvalidHostURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://www.google.com"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Should be an invalid Rouxbe URL.");
}

/**
 * Test a URL that points to rouxbe.com but has the wrong path. 
 * Should also return NO when validating.
 */
- (void)testRouxbeURLWithInvalidPath
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Should be an invalid Rouxbe URL.");
}

@end
