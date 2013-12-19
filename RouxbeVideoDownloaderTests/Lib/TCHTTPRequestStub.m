//
//  TCStubRouxbeService.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCHTTPRequestStub.h"

@implementation TCHTTPRequestStub

+ (void)initialize
{
    [OHHTTPStubs onStubActivation:^(NSURLRequest *request, id<OHHTTPStubsDescriptor> stub) {
        NSLog(@"<%@> stubbed by <%@>", request.URL.absoluteString, stub.name);
    }];
}

+ (id<OHHTTPStubsDescriptor>)stubAllRouxbeRequestsToReturnSuccessResponse
{
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [self isRouxbeBaseURL:request.URL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [self responseForRequest:request];
    }];
    stub.name = @"TCBaseStub";

    return stub;
}

+ (id<OHHTTPStubsDescriptor>)stubLessonRequestToReturnResponseWithError:(NSError *)error
{
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) { return [self isLessonPath:request.URL.pathComponents]; }
                       withResponseError:error
                                    name:@"TCBaseStub.LessonErrorStub"];
}

+ (id<OHHTTPStubsDescriptor>)stubLessonStepVideoRequestToReturnResponseWithError:(NSError *)error
{
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) { return [self isLessonStepVideoPath:request.URL.pathComponents]; }
                       withResponseError:error
                                    name:@"TCBaseStub.LessonStepErrorStub"];
}

+ (id<OHHTTPStubsDescriptor>)stubRecipeRequestToReturnResponseWithError:(NSError *)error
{
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) { return [self isRecipePath:request.URL.pathComponents]; }
                       withResponseError:error
                                    name:@"TCBaseStub.RecipeErrorStub"];

}

+ (id<OHHTTPStubsDescriptor>)stubTipRequestToReturnResponseWithError:(NSError *)error
{
    return [self stubRequestsPassingTest:^BOOL(NSURLRequest *request) { return [self isTipVideoPath:request.URL.pathComponents]; }
                       withResponseError:error
                                    name:@"TCBaseStub.TipErrorStub"];
}

+(id<OHHTTPStubsDescriptor>)stubRequestsPassingTest:(OHHTTPStubsTestBlock)testBlock
                                  withResponseError:(NSError *)error
                                               name:(NSString *)name
{
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:testBlock withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [OHHTTPStubsResponse responseWithError:error];
    }];
    stub.name = name;

    return stub;
}

+ (void)stopStubbingRequests
{
    [OHHTTPStubs removeAllStubs];
}

#pragma mark - Private Helper Methods

+ (OHHTTPStubsResponse *)responseForRequest:(NSURLRequest *)request
{
    NSArray *pathComponents = request.URL.pathComponents;

    if ([self isLessonPath:pathComponents]) {
        return [self responseWithFile:@"Lesson.xml"];
    } else if ([self isRecipePath:pathComponents]) {
        return [self responseWithFile:@"Recipe.xml"];
    } else if ([self isLessonStepVideoPath:pathComponents]) {
        return [self responseWithFile:@"LessonStepVideo.xml"];
    } else if ([self isTipVideoPath:pathComponents]) {
        return [self responseWithFile:@"Tip.xml"];
    }

    return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                      code:NSURLErrorUnsupportedURL
                                                                  userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Request URL was not stubbed because it does not match any known URL.", nil)}]];
}

+ (OHHTTPStubsResponse *)responseWithFile:(NSString *)fileName
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    
    return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fileName, testBundle)
                                            statusCode:200
                                               headers:@{@"Content-Type": @"application/xml"}];
}

/**
 * Returns \c YES if \c theURL matches http://rouxbe.com; \c NO otherwise.
 */
+ (BOOL)isRouxbeBaseURL:(NSURL *)theURL
{
    return [theURL.scheme isEqualToString:@"http"] &&
           [theURL.host isEqualToString:@"rouxbe.com"];
}

+ (BOOL)isLessonPath:(NSArray *)pathComponents
{
    // Example URL = http://rouxbe.com/cooking-school/lessons/170.xml
    // Path Components = ["/", "cooking-school", "lessons", "170.xml"]
    return [pathComponents[1] isEqualToString:@"cooking-school"];
}

+ (BOOL)isLessonStepVideoPath:(NSArray *)pathComponents
{
    // Example URL = http://rouxbe.com/embedded_player/settings_section/101.xml
    // Path Components = ["/", "embedded_player", "settings_section", "101.xml"]
    return [pathComponents[1] isEqualToString:@"embedded_player"] &&
           [pathComponents[2] isEqualToString:@"settings_section"];
}

+ (BOOL)isRecipePath:(NSArray *)pathComponents
{
    // Example URL = http://rouxbe.com/recipes/89.xml
    // Path Components = ["/", "recipes", "89.xml"]
    return [pathComponents[1] isEqualToString:@"recipes"];
}

+ (BOOL)isTipVideoPath:(NSArray *)pathComponents
{
    // Example URL = http://rouxbe.com/embedded_player/settings_drilldown/202.xml
    // Path Components = ["/", "embedded_player", "settings_drilldown", "202.xml"]
    return [pathComponents[1] isEqualToString:@"embedded_player"] &&
           [pathComponents[2] isEqualToString:@"settings_drilldown"];
}

@end
