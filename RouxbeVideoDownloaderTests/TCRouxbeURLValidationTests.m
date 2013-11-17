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
 * @test
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
 * @test
 * Test that a valid Rouxbe Lesson URL should return YES when validating.
 */
- (void)testValidLessonURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Lesson URL.");
}

/**
 * @test
 * Test that a valid Rouxbe Lesson URL with a sub-category should also
 * return YES when validating.
 */
- (void)testValidLessonSubcategoryURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry/details"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Lesson URL with a sub-category.");
}

/**
 * @test
 * Test that a valid Rouxbe Tip URL should return YES when validating.
 */
- (void)testValidTipURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/60-why-meat-needs-to-rest-after-cooking"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Tips & Techniques URL.");
}

/**
 * @test
 * Test that a valid Rouxbe Tip URL with a sub-category should also
 * return YES when validating.
 */
- (void)testValidTipSubcategoryURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/60-why-meat-needs-to-rest-after-cooking/preview"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Tip URL with a sub-category.");
}

/**
 * @test
 * Test that a valid Rouxbe Recipe URL should return YES when validating.
 */
- (void)testValidRecipeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Recipe URL.");
}

/**
 * @test
 * Test that a valid Rouxbe Recipe URL with a sub-category should also
 * return YES when validating.
 */
- (void)testValidRecipeSubcategoryURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew/text"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertTrue(result, @"Should be a valid Rouxbe Recipe URL with a sub-category.");
}

#pragma mark - Test Invalid URLs

/**
 * @test
 * Test that a URL with the wrong scheme should return NO when validating.
 */
- (void)testInvalidSchemeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"ftp://rouxbe.com/recipes/89-chicken-cashew"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Scheme should be invalid.");
}

/**
 * @test
 * Test that a URL with the wrong host should return NO when validating.
 */
- (void)testInvalidHostURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://www.google.com"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Host should be invalid.");
}

/**
 * @test
 * Test a URL that points to rouxbe.com but has no path
 * should return NO when validating.
 */
- (void)testRouxbeURLWithNoPath
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"URL with no path should be invalid.");
}

/**
 * @test
 * Test a URL that has an unknown category should return 
 * NO when validating.
 */
- (void)testRouxbeURLWithUnknownCategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-courses/egg-basics/details"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Category should not be valid.");
}

/**
 * @test
 * Test a Lesson URL that is incomplete should return
 * NO when validating.
 */
- (void)testRouxbeLessonURLIncomplete
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Incomplete Lesson URL should be invalid.");
}

/**
 * @test
 * Test a Lesson URL that does not have an ID should return
 * NO when validating.
 */
- (void)testRouxbeLessonURLWithNoID
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/how-to-pan-fry"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Lesson URL without an ID should be invalid.");
}

/**
 * @test
 * Test a Recipe URL that is incomplete should return
 * NO when validating.
 */
- (void)testRouxbeRecipeURLIncomplete
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Incomplete Recipe URL should be invalid.");
}

/**
 * @test
 * Test a Recipe URL that does not have an ID should return
 * NO when validating.
 */
- (void)testRouxbeRecipeURLWithNoID
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/chicken-cashew"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Recipe URL without an ID should be invalid.");
}

/**
 * @test
 * Test a Tip & Technique URL that is incomplete should return
 * NO when validating.
 */
- (void)testRouxbeTipURLIncomplete
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Incomplete Tip & Technique URL should be invalid.");
}

/**
 * @test
 * Test a Tip & Technique  URL that does not have an ID should return
 * NO when validating.
 */
- (void)testRouxbeTipURLWithNoID
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/what-are-pappadams-indian-flatbread"];
    BOOL result = [testURL isValidRouxbeURL];

    XCTAssertFalse(result, @"Tip & Technique URL without an ID should be invalid.");
}

@end
