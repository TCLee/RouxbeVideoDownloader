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
    });

    return _sharedService;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        // Configure the response serializer to handle XML responses and
        // return the response object as a plain NSData.
        AFHTTPResponseSerializer *XMLResponseSerializer = [[AFHTTPResponseSerializer alloc] init];
        XMLResponseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
        self.responseSerializer = XMLResponseSerializer;
    }
    return self;
}

@end
