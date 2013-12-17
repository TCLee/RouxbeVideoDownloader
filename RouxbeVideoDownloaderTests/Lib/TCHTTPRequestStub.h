//
//  TCStubRouxbeService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@interface TCHTTPRequestStub : NSObject

+ (id<OHHTTPStubsDescriptor>)beginStubRequests;

+ (void)stopStubRequests;

@end
