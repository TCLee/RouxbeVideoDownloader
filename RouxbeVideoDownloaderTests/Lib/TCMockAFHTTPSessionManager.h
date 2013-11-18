//
//  TCMockAFHTTPSessionManager.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

typedef void(^AFHTTPSessionManagerSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^AFHTTPSessionManagerFailureBlock)(NSURLSessionDataTask *task, NSError *error);
typedef NSURLSessionDataTask *(^AFHTTPSessionManagerGETBlock)(NSString *URLString, NSDictionary *parameters, AFHTTPSessionManagerSuccessBlock success, AFHTTPSessionManagerFailureBlock failure);
typedef void(^AFHTTPSessionManagerSetResponseSerializerBlock)(AFHTTPResponseSerializer *responseSerializer);

@interface TCMockAFHTTPSessionManager : NSObject

+ (id)mockHTTPSessionManagerWithGETBlock:(AFHTTPSessionManagerGETBlock)GETBlock;

+ (id)mockHTTPSessionManagerWithSetResponseSerializerBlock:(AFHTTPSessionManagerSetResponseSerializerBlock)setResponseSerializerBlock;

@end
