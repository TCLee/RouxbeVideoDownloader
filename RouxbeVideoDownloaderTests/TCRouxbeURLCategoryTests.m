//
//  TCRouxbeURLUtilitiesTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "NSURL+RouxbeAdditions.h"

/**
 * This test class contains test methods to verify that we can extract 
 * the category from the given Rouxbe URL.
 */
@interface TCRouxbeURLCategoryTests : XCTestCase

@end

@implementation TCRouxbeURLCategoryTests

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
 * Test that given a valid Lesson URL, we can determine that it is 
 * a Lesson category.
 */
- (void) testLessonCategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry"];
    TCRouxbeCategory category = [testURL rouxbeCategory];

    XCTAssert(TCRouxbeCategoryLesson == category, @"URL should have been a Lesson category.");
}

/**
 * Test that given a valid Recipe URL, we can determine that it is
 * a Recipe category.
 */
- (void) testRecipeCategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew"];
    TCRouxbeCategory category = [testURL rouxbeCategory];

    XCTAssert(TCRouxbeCategoryRecipe == category, @"URL should have been a Recipe category.");
}

/**
 * Test that given a valid Tip & Technique URL, we can determine that it is
 * a Tip & Technique category.
 */
- (void) testTipCategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread"];
    TCRouxbeCategory category = [testURL rouxbeCategory];

    XCTAssert(TCRouxbeCategoryTip == category, @"URL should have been a Tips & Technique category.");
}

/**
 * Test that given an invalid Rouxbe URL, it will return the category 
 * as 'Unknown'.
 */
- (void) testUnknownCategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-courses"];
    TCRouxbeCategory category = [testURL rouxbeCategory];

    XCTAssert(TCRouxbeCategoryUnknown == category, @"URL should have been an Unknown category.");
}

@end
