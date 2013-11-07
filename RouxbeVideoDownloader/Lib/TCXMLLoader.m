//
//  TCXMLLoader.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCXMLLoader.h"

@implementation TCXMLLoader

+ (void)loadXMLFromURL:(NSURL *)xmlURL completion:(void (^)(RXMLElement *rootElement, NSError *error))completion
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:[xmlURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RXMLElement *rootElement = [[RXMLElement alloc] initFromXMLData:responseObject];
        completion(rootElement, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];

}

@end
