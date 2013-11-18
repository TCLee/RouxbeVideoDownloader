//
//  TCRouxbeAPIClient.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * The block that will be called when XML request has completed.
 *
 * @param data  The \c NSData containing the XML.
 * @param error The \c NSError object describing the error, if any.
 */
typedef void(^TCRouxbeAPIClientGetXMLCompletionHandler)(NSData *data, NSError *error);

/**
 * \c TCRouxbeAPIClient is the single point of access to access 
 * rouxbe.com web services.
 *
 * \c TCRouxbeAPIClient manages an application-wide session object
 * that will be used to create data and download tasks.
 */
@interface TCRouxbeAPIClient : AFHTTPSessionManager

/**
 * Returns the default API client used in the application.
 *
 * @return The default API client.
 */
+ (instancetype)sharedClient;

/**
 * <#Description#>
 *
 * @param path              <#path description#>
 * @param completionHandler <#completionHandler description#>
 *
 * @return <#return value description#>
 */
- (NSURLSessionDataTask *)getXML:(NSString *)path
               completionHandler:(TCRouxbeAPIClientGetXMLCompletionHandler)completionHandler;

@end
