//
//  TCMockXMLService.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCMockXMLService.h"

@implementation TCMockXMLService

+ (id)mockXMLServiceWithRequestXMLBlock:(TCMockXMLServiceRequestXMLBlock)requestXML
{
    id mock = [OCMockObject mockForClass:[TCXMLService class]];

    void(^mockBlock)(NSInvocation *) = ^(NSInvocation *invocation) {
        NSURL *requestURL = [[invocation getArgumentAtIndexAsObject:2] copy];
        TCXMLServiceBlock completionBlock = [[invocation getArgumentAtIndexAsObject:3] copy];
        requestXML(requestURL, completionBlock);
    };

    [[[[mock stub] classMethod] andDo:mockBlock]
     requestXMLDataWithURL:OCMOCK_ANY completion:OCMOCK_ANY];

    return mock;
}

@end
