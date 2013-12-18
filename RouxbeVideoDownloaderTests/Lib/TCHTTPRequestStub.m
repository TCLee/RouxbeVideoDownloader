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

+ (id<OHHTTPStubsDescriptor>)beginStubRequests
{
    id<OHHTTPStubsDescriptor> stub = [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.scheme isEqualToString:@"http"] &&
               [request.URL.host isEqualToString:@"rouxbe.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [self responseForRequest:request];
    }];
    stub.name = @"TCHTTPRequestStub";

    return stub;
}

+ (void)stopStubRequests
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
                                               headers:@{@"Content-Type":@"application/xml"}];
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
