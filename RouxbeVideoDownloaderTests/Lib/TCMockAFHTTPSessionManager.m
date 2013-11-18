//
//  TCMockAFHTTPSessionManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMockAFHTTPSessionManager.h"

@implementation TCMockAFHTTPSessionManager

+ (id)mockHTTPSessionManagerWithSetResponseSerializerBlock:(AFHTTPSessionManagerSetResponseSerializerBlock)setResponseSerializerBlock
{
    id mock = [OCMockObject niceMockForClass:[AFHTTPSessionManager class]];

    void(^mockBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        AFHTTPResponseSerializer *responseSerializer = [[invocation getArgumentAtIndexAsObject:2] copy];
        if (setResponseSerializerBlock) {
            setResponseSerializerBlock(responseSerializer);
        }
    };

    [[[mock stub] andDo:mockBlock] setResponseSerializer:OCMOCK_ANY];

    return mock;
}

+ (id)mockHTTPSessionManagerWithGETBlock:(AFHTTPSessionManagerGETBlock)GETBlock
{
    id mock = [OCMockObject niceMockForClass:[AFHTTPSessionManager class]];

    void(^mockBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSString *URLString = [[invocation getArgumentAtIndexAsObject:2] copy];
        NSDictionary *parameters = [[invocation getArgumentAtIndexAsObject:3] copy];
        AFHTTPSessionManagerSuccessBlock success = [[invocation getArgumentAtIndexAsObject:4] copy];
        AFHTTPSessionManagerFailureBlock failure = [[invocation getArgumentAtIndexAsObject:5] copy];

        if (GETBlock) {
            GETBlock(URLString, parameters, success, failure);
        }
    };

    [[[mock stub] andDo:mockBlock] GET:OCMOCK_ANY
                            parameters:OCMOCK_ANY
                               success:OCMOCK_ANY
                               failure:OCMOCK_ANY];

    return mock;
}

@end
