//
//  TCXMLService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/12/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * The block that will be called when request has completed.
 *
 * @param data  The \c NSData containing the XML.
 * @param error The \c NSError object describing the error, if any.
 */
typedef void(^TCXMLServiceBlock)(NSData *data, NSError *error);

/**
 * \c TCXMLService class fetches XML data from a given URL.
 */
@interface TCXMLService : NSObject

/**
 * Fetch XML data from the request URL using the given session manager.
 *
 * @param sessionManager The \c AFHTTPSessionManager that manages the current session.
 * @param requestURL     The request URL.
 * @param completion     The completion block that will be called when request has finished.
 */
+ (void)requestXMLDataWithSessionManager:(AFHTTPSessionManager *)sessionManager
                                     URL:(NSURL *)requestURL
                              completion:(TCXMLServiceBlock)completion;

/**
 * Fetch XML data from the request URL using the default session manager.
 *
 * @param requestURL     The request URL.
 * @param completion     The completion block that will be called when request has finished.
 */
+ (void)requestXMLDataWithURL:(NSURL *)requestURL
                   completion:(TCXMLServiceBlock)completion;

@end
