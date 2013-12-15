//
//  TCTestDataLoader.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCTestDataLoader class provides an interface to load test data
 * from the unit test bundle.
 */
@interface TCTestDataLoader : NSObject

/**
 * Returns the contents of an XML file in the test bundle with the given
 * filename.
 *
 * Raises an \c NSInternalInconsistencyException, if failed to load 
 * XML document.
 *
 * @param name The filename of the XML document.
 *
 * @return A \c NSData object representing the XML document or \c nil on error.
 */
+ (NSData *)XMLDataWithName:(NSString *)name;

/**
 * Returns the contents of an XML file in the test bundle with the given
 * filename and out error parameter.
 *
 * @param name     The filename of the XML document.
 * @param outError If there's an error reading in the data, it will contain
 *                 an NSError object that describes the problem.
 *
 * @return A \c NSData object representing the XML document or \c nil on error.
 */
+ (NSData *)XMLDataWithName:(NSString *)name
                      error:(NSError *__autoreleasing *)outError;

@end
