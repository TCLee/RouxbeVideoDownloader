//
//  TCRouxbeService.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCRouxbeService.h"

/**
 * Base URL for rouxbe.com web services.
 */
static NSString * const TCRouxbeBaseURLString = @"http://rouxbe.com/";

@implementation TCRouxbeService

+ (instancetype)sharedService
{
    static TCRouxbeService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[TCRouxbeService alloc] initWithBaseURL:[NSURL URLWithString:TCRouxbeBaseURLString]];

        // Configure the response serializer to handle XML responses.
        AFHTTPResponseSerializer *XMLDataSerializer = [[AFHTTPResponseSerializer alloc] init];
        XMLDataSerializer.stringEncoding = NSUTF8StringEncoding;
        XMLDataSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
        _sharedService.responseSerializer = XMLDataSerializer;
    });

    return _sharedService;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithPath:(NSString *)path
                                                 success:(TCRouxbeServiceSuccessBlock)success
                                                 failure:(TCRouxbeServiceFailureBlock)failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET"
                                                                   URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString]
                                                                  parameters:nil];
    return [self HTTPRequestOperationWithRequest:request
                                         success:success
                                         failure:failure];
}

@end
