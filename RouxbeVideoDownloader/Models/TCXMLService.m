//
//  TCXMLService.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/12/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCXMLService.h"

@interface TCXMLService ()

@end

@implementation TCXMLService

+ (void)requestXMLDataWithSessionManager:(AFHTTPSessionManager *)sessionManager
                                     URL:(NSURL *)requestURL
                              completion:(TCXMLServiceBlock)completion
{
    NSParameterAssert(requestURL);

    // Configure the response data to be serialized as an XML data.
    AFHTTPResponseSerializer *XMLResponseSerializer = [[AFHTTPResponseSerializer alloc] init];
    XMLResponseSerializer.stringEncoding = NSUTF8StringEncoding;
    XMLResponseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
    sessionManager.responseSerializer = XMLResponseSerializer;

    // Create and start a NSURLSessionDataTask to fetch the XML data.
    // The NSURLSessionDataTask will be added to the default NSURLSession
    // created by AFHTTPSessionManager.
    [sessionManager GET:[requestURL absoluteString] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            completion(responseObject, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(nil, error);
        }
    }];
}

+ (void)requestXMLDataWithURL:(NSURL *)requestURL
                   completion:(TCXMLServiceBlock)completion
{
    [self requestXMLDataWithSessionManager:[AFHTTPSessionManager manager]
                                       URL:requestURL
                                completion:completion];
}

@end
