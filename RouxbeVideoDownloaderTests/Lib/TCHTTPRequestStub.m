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
        return [request.URL.host isEqualToString:@"rouxbe.com"];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSArray *pathComponents = request.URL.pathComponents;

        if ([pathComponents[1] isEqualToString:@"cooking-school"]) {
            return [self responseWithFile:@"Lesson.xml"];
        } else if ([pathComponents[1] isEqualToString:@"recipes"]) {
            return [self responseWithFile:@"Recipe.xml"];
        } else if ([pathComponents[1] isEqualToString:@"embedded_player"]) {
            if ([pathComponents[2] isEqualToString:@"settings_section"]) {
                return [self responseWithFile:@"LessonStepVideo.xml"];
            } else if ([pathComponents[2] isEqualToString:@"settings_drilldown"]) {
                return [self responseWithFile:@"Tip.xml"];
            }
        }

        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain
                                                                          code:NSURLErrorUnsupportedURL
                                                                      userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Request URL was not stubbed because it does not match any known URL.", nil)}]];
    }];
    stub.name = @"Rouxbe Web Service Stub";

    return stub;
}

+ (OHHTTPStubsResponse *)responseWithFile:(NSString *)fileName
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];

    return [OHHTTPStubsResponse responseWithFileAtPath:OHPathForFileInBundle(fileName, testBundle)
                                            statusCode:200
                                               headers:@{@"Content-Type":@"application/xml"}];
}

+ (void)stopStubRequests
{
    [OHHTTPStubs removeAllStubs];
}

@end
