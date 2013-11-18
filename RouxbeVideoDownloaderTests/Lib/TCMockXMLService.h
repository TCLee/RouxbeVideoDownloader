//
//  TCMockXMLService.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCXMLService.h"

/**
 * Block signature that matches the 
 * TCXMLService::requestXMLDataWithURL:completion: method.
 */
typedef void(^TCMockXMLServiceRequestXMLBlock)(NSURL *requestURL, TCXMLServiceBlock completionBlock);

/**
 * Creates \c TCXMLService mock object.
 */
@interface TCMockXMLService : NSObject

/**
 * Creates and returns a mock of \c TCXMLService class with its method
 * \c requestXMLDataWithURL:completion: replaced with given block.
 *
 * @param requestXML The block to replace the
 *                   requestXMLDataWithURL:completion: method with.
 *
 * @return A mock of \c TCXMLService class.
 */
+ (id)mockXMLServiceWithRequestXMLBlock:(TCMockXMLServiceRequestXMLBlock)requestXML;

@end
