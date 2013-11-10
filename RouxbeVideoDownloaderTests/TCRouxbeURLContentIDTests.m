//
//  TCRouxbeURLContentIDTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "NSURL+RouxbeAdditions.h"

/**
 * @test
 * This test class contains test methods to verify that we can successfully 
 * extract the Rouxbe ID from the URL.
 */
@interface TCRouxbeURLContentIDTests : XCTestCase

@end

@implementation TCRouxbeURLContentIDTests

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
 * Test that we can get the ID from a valid Rouxbe Lesson URL.
 */
- (void) testGetIDFromRouxbeLessonURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 170, @"Lesson ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that we can get the ID from a Rouxbe Lesson URL 
 * with a subcategory.
 */
- (void) testGetIDFromRouxbeLessonURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry/details"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 170, @"Lesson ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that we can get the ID from a valid Rouxbe Recipe URL.
 */
- (void) testGetIDFromRouxbeRecipeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 89, @"Recipe ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that we can get the ID from a Rouxbe Recipe URL
 * with a subcategory.
 */
- (void) testGetIDFromRouxbeRecipeURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew/text"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 89, @"Recipe ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that we can get the ID from a valid Rouxbe Tip URL.
 */
- (void) testGetIDFromRouxbeTipURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 98, @"Tip ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that we can get the ID from a Rouxbe Tip URL
 * with a subcategory.
 */
- (void) testGetIDFromRouxbeTipURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread/preview"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == 98, @"Tip ID does not match the ID in the URL.");
}

/**
 * @test
 * Test that attempting to get an ID from an invalid Rouxbe URL 
 * should return NSNotFound for the ID.
 */
- (void)testGetIDFromInvalidRouxbeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://www.google.com"];
    NSUInteger contentID = [testURL rouxbeID];

    XCTAssertTrue(contentID == NSNotFound, @"For an invalid URL, should return NSNotFound for the ID.");
}

@end
