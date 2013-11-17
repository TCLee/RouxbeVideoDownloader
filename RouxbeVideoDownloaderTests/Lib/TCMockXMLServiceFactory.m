//
//  TCMockXMLServiceFactory.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMockXMLServiceFactory.h"

@implementation TCMockXMLServiceFactory

+ (id)mockXMLServiceWithBlock:(TCMockXMLServiceBlock)mockBlock
{
    id mock = [OCMockObject mockForClass:[TCXMLService class]];

    void(^invocationBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSURL *requestURL = [[invocation getArgumentAtIndexAsObject:2] copy];
        TCXMLServiceBlock completionBlock = [[invocation getArgumentAtIndexAsObject:3] copy];
        mockBlock(requestURL, completionBlock);
    };

    [[[[mock stub] classMethod] andDo:invocationBlock]
     requestXMLDataWithURL:OCMOCK_ANY completion:OCMOCK_ANY];

    return mock;
}

@end
