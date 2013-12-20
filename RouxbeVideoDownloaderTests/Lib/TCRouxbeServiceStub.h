//
//  TCRouxbeServiceStub.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@interface TCRouxbeServiceStub : NSObject

+ (id<OHHTTPStubsDescriptor>)stubAllRequestsToReturnSuccessResponse;

+ (id<OHHTTPStubsDescriptor>)stubLessonRequestToReturnResponseWithError:(NSError *)error;
+ (id<OHHTTPStubsDescriptor>)stubLessonStepVideoRequestToReturnResponseWithError:(NSError *)error;
+ (id<OHHTTPStubsDescriptor>)stubRecipeRequestToReturnResponseWithError:(NSError *)error;
+ (id<OHHTTPStubsDescriptor>)stubTipRequestToReturnResponseWithError:(NSError *)error;

+ (void)stopStubbingRequests;

@end
