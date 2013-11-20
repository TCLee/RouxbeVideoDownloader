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

- (NSURLSessionDataTask *)getXML:(NSString *)path
                         success:(TCRouxbeServiceSuccessBlock)success
                         failure:(TCRouxbeServiceFailureBlock)failure
{
    NSParameterAssert(path);

    return [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (success) {
            success(task, responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
        }
    }];
}

@end
