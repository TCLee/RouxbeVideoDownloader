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

/**
 * Creates \c AFHTTPSessionManager mock objects.
 */
@interface TCMockAFHTTPSessionManager : NSObject

/**
 * Creates a \c AFHTTPSessionManager mock object with
 * GET:parameters:success:failure: method replaced with the given block.
 *
 * @param GETBlock The block to replace GET:parameters:success:failure: method with.
 *
 * @return A \c AFHTTPSessionManager mock object.
 */
+ (id)mockHTTPSessionManagerWithGETBlock:(AFHTTPSessionManagerGETBlock)GETBlock;

/**
 * Creates a \c AFHTTPSessionManager mock object with 
 * setResponseSerializer: method replaced with the given block.
 *
 * @param setResponseSerializerBlock The block to replace setResponseSerializer: method with.
 *
 * @return A \c AFHTTPSessionManager mock object.
 */
+ (id)mockHTTPSessionManagerWithSetResponseSerializerBlock:(AFHTTPSessionManagerSetResponseSerializerBlock)setResponseSerializerBlock;

@end
