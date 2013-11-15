//
//  TCXMLService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/12/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCXMLService class fetches XML data from a given URL.
 */
@interface TCXMLService : NSObject

/**
 * Fetch the XML data from the given URL and calls the  handler upon completion.
 *
 * @param aURL The URL of the XML data.
 * @param completion The completion handler to call when the request is complete.
 *                   On success, the \c data parameter will contain the XML data. 
 *                   On error, the \c error parameter will contain an \c NSError 
 *                   object describing the failure.
 */
+ (void)requestXMLDataWithURL:(NSURL *)aURL
                   completion:(void (^)(NSData *data, NSError *error))completion;

@end
