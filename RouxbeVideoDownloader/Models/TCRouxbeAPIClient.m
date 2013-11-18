//
//  TCRouxbeAPIClient.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCRouxbeAPIClient.h"

static NSString * const TCRouxbeBaseURLString = @"http://rouxbe.com/";

@implementation TCRouxbeAPIClient

+ (instancetype)sharedClient
{
    static TCRouxbeAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[TCRouxbeAPIClient alloc] initWithBaseURL:[NSURL URLWithString:TCRouxbeBaseURLString]];

        // rouxbe.com returns XML responses in their web services.
        AFHTTPResponseSerializer *XMLResponseSerializer = [[AFHTTPResponseSerializer alloc] init];
        XMLResponseSerializer.stringEncoding = NSUTF8StringEncoding;
        XMLResponseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
        _sharedClient.responseSerializer = XMLResponseSerializer;
    });

    return _sharedClient;
}

- (NSURLSessionDataTask *)getXML:(NSString *)path
               completionHandler:(TCRouxbeAPIClientGetXMLCompletionHandler)completionHandler
{
    NSParameterAssert(path);

    return [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completionHandler) {
            completionHandler(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

@end
