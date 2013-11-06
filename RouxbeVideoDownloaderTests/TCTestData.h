//
//  TCTestData.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCTestData : NSObject

/**
 * Returns the XML document with the given filename as a \c NSData object.
 *
 * @param name The filename of the XML document.
 *
 * @return A \c NSData object representing the XML document.
 */
+ (NSData *)XMLDataWithName:(NSString *)name;

@end
