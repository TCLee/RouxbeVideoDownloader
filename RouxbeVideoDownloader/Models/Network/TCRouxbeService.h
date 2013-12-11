//
//  TCRouxbeService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/18/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCRouxbeService is a subclass of \c AFHTTPRequestOperationManager 
 * that manages the HTTP request operations to Rouxbe's web services.
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
