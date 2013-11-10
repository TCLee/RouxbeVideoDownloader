//
//  TCRouxbeXMLURLTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "NSURL+RouxbeAdditions.h"

/**
 * @test
 * This test class contains test methods to verify that we can get an XML 
 * representation of a Rouxbe URL's resource.
 */
@interface TCRouxbeXMLURLTests : XCTestCase

@end

@implementation TCRouxbeXMLURLTests

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
 * Test that we can get the XML URL from a Lesson URL.
 */
- (void)testGetXMLURLFromLessonURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that we can get the XML URL from a Lesson URL with a sub-category.
 */
- (void)testGetXMLURLFromLessonURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry/details"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/cooking-school/lessons/170.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that we can get the XML URL from a Recipe URL.
 */
- (void)testGetXMLURLFromRecipeURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that we can get the XML URL from a Recipe URL with a sub-category.
 */
- (void)testGetXMLURLFromRecipeURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89-chicken-cashew/text"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/89.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that we can get the XML URL from a Tip URL.
 */
- (void)testGetXMLURLFromTipURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that we can get the XML URL from a Tip URL with a sub-category.
 */
- (void)testGetXMLURLFromTipURLWithSubcategory
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread/text"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    NSURL *expectedURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/tips-techniques/98.xml"];
    XCTAssertTrue([xmlURL isEqual:expectedURL], @"Expected XML URL is %@", [expectedURL absoluteString]);
}

/**
 * @test
 * Test that XML URL will return \c nil if given an invalid URL.
 */
- (void)testGetXMLURLFromInvalidURL
{
    NSURL *testURL = [[NSURL alloc] initWithString:@"http://rouxbe.com/recipes/chicken-cashew"];
    NSURL *xmlURL = [testURL rouxbeXMLDocumentURL];

    XCTAssertNil(xmlURL, @"There should be no XML URL for an invalid URL.");
}

@end
