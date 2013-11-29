//
//  TCRouxbeService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

typedef void(^TCRouxbeServiceSuccessBlock)(AFHTTPRequestOperation *operation , id responseObject);
typedef void(^TCRouxbeServiceFailureBlock)(AFHTTPRequestOperation *operation , NSError *error);

/**
 * \c TCRouxbeService class manages the session for HTTP requests to
 * \c rouxbe.com web services. It provides a single point of access to
 * all the web services.
 */
@interface TCRouxbeService : AFHTTPRequestOperationManager

/**
 * Returns the default service object used to make requests to the 
 * web services.
 *
 * @return The default service object.
 */
+ (instancetype)sharedService;

/**
 * Creates an \c AFHTTPRequestOperation with its request contructed from the 
 * given relative path to the base URL.
 *
 * @see AFHTTPRequestOperationManager::HTTPRequestOperationWithRequest:success:failure:
 *
 * @param path    The relative path to the base URL.
 * @param success A block object to be executed when the request operation finishes successfully.
 * @param failure A block object to be executed when the request operation failed with an error.
 *
 * @return An \c AFHTTPRequestOperation object
 */
- (AFHTTPRequestOperation *)HTTPRequestOperationWithPath:(NSString *)path
                                                 success:(TCRouxbeServiceSuccessBlock)success
                                                 failure:(TCRouxbeServiceFailureBlock)failure;
@end
