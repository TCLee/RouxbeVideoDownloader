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
 * Fetch the XML data from the given URL and calls the  handler upon completion.
 *
 * @param aURL The URL of the XML data.
 * @param completion The completion handler to call when the request is complete.
 */
+ (void)requestXMLDataWithURL:(NSURL *)aURL
                   completion:(TCXMLServiceBlock)completion;

@end
