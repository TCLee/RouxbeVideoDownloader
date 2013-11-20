//
//  TCRouxbeService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * Block that will be executed when task has finished successfully.
 *
 * @param task The task object.
 * @param data A \c NSData object containing the XML.
 */
typedef void(^TCRouxbeServiceSuccessBlock)(NSURLSessionDataTask *task, NSData *data);

/**
 * Block that will be executed when task has failed.
 *
 * @param task  The task object.
 * @param error A \c NSError object containing the description of the failure.
 */
typedef void(^TCRouxbeServiceFailureBlock)(NSURLSessionDataTask *task, NSError *error);

/**
 * \c TCRouxbeService class manages the session for HTTP requests to
 * \c rouxbe.com web services. It provides a single point of access to
 * all the web services.
 */
@interface TCRouxbeService : AFHTTPSessionManager

/**
 * Returns the default service object used to make requests to the 
 * web services.
 *
 * @return The default service object.
 */
+ (instancetype)sharedService;

/**
 * Creates and runs a \c NSURLSessionDataTask with a \c GET request to 
 * fetch XML data from the given path.
 *
 * @param path     The relative path from the base url to the XML.
 * @param success  A block object to be executed when the task finishes successfully.
 * @param failure  A block object to be executed when the task fails.
 *
 * @return The \c NSURLSessionDataTask object that was created to fetch the XML. 
 *         This task's state will be \c NSURLSessionTaskStateRunning when it's returned.
 */
- (NSURLSessionDataTask *)getXML:(NSString *)path
                         success:(TCRouxbeServiceSuccessBlock)success
                         failure:(TCRouxbeServiceFailureBlock)failure;
@end
