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

@end
