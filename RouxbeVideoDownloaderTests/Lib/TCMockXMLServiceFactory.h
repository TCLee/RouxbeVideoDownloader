//
//  TCMockXMLServiceFactory.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/17/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCXMLService.h"

/**
 * The block signature used to mock
 * TCXMLService::requestXMLDataWithURL:completion: class method.
 *
 * @param requestURL      The request URL passed into the mock method.
 * @param completionBlock The completion block to call before the
 *                        mock method returns.
 */
typedef void(^TCMockXMLServiceBlock)(NSURL *requestURL, TCXMLServiceBlock completionBlock);

/**
 * Factory to create a \c TCXMLService mock object.
 */
@interface TCMockXMLServiceFactory : NSObject

/**
 * Creates and returns a mock of \c TCXMLService class with its method
 * \c requestXMLDataWithURL:completion: replaced with \c mockBlock.
 *
 * @param mockBlock The block to replace the 
 *                  requestXMLDataWithURL:completion: method with.
 *
 * @return A mock of \c TCXMLService class.
 */
+ (id)mockXMLServiceWithBlock:(TCMockXMLServiceBlock)mockBlock;

@end
