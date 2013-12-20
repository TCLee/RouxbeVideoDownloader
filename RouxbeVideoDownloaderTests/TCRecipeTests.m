//
//  TCRecipeTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCRecipe.h"

@interface TCRecipeTests : XCTestCase

@property (readwrite, nonatomic, assign) NSUInteger recipeID;
@property (readwrite, nonatomic, copy) OHHTTPStubsTestBlock stubRecipeRequestBlock;

@end

@implementation TCRecipeTests

- (void)setUp
{
    [super setUp];

    self.recipeID = 89;

    self.stubRecipeRequestBlock = ^BOOL(NSURLRequest *request) {
        return [request.URL.absoluteString isEqualToString:@"http://rouxbe.com/recipes/89.xml"];
    };
}

- (void)tearDown
{
    [OHHTTPStubs removeAllStubs];

    self.recipeID = NSNotFound;
    self.stubRecipeRequestBlock = nil;

    [super tearDown];
}

- (void)testFetchRecipeWithSuccessShouldCallCompletionBlockWithGroup
{
    [OHHTTPStubs stubRequestsPassingTest:self.stubRecipeRequestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(@"Recipe.xml", nil)
                                                statusCode:200
                                                   headers:nil];
    }];

    __block TCGroup *blockGroup = nil;
    __block NSError *blockError = nil;
    [TCRecipe getRecipeWithID:self.recipeID completeBlock:^(TCGroup *group, NSError *error) {
        blockGroup = group;
        blockError = error;
    }];

    expect(blockError).will.beNil();
    expect(blockGroup).willNot.beNil();

    expect(blockGroup.ID).will.equal(self.recipeID);
    expect(blockGroup.name).will.equal(@"Chicken Cashew");
}

- (void)testFetchRecipeWithFailureShouldCallCompletionBlockWithError
{
    [OHHTTPStubs stubRequestsPassingTest:self.stubRecipeRequestBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorTimedOut
                                                                      userInfo:nil]];
    }];

    __block TCGroup *blockGroup = nil;
    __block NSError *blockError = nil;
    [TCRecipe getRecipeWithID:self.recipeID completeBlock:^(TCGroup *group, NSError *error) {
        blockGroup = group;
        blockError = error;
    }];

    expect(blockGroup).will.beNil();
    expect(blockError).willNot.beNil();
    expect(blockError.code).will.equal(NSURLErrorTimedOut);
}

@end
