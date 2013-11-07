//
//  TCXMLLoader.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCXMLLoader class provides an interface to asynchronously load
 * XML documents from a given URL.
 */
@interface TCXMLLoader : NSObject

/**
 * Loads the XML data from the given URL and returns a reference to the root 
 * element of the XML document.
 *
 * @param xmlURL The URL to the XML document.
 * @param completion The completion block that will be called when the 
 *                   XML document has finished loading. On success, the \c rootElement will 
 *                   be the reference to the XML document's root element. On 
 *                   failure, \c error will contain a description of the failure.
 */
+ (void)loadXMLFromURL:(NSURL *)xmlURL completion:(void (^)(RXMLElement *rootElement, NSError *error))completion;

@end
