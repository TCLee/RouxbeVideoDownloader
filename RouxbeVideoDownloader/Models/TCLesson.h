//
//  TCLesson.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * \c TCLesson object describes a lesson in Rouxbe's Cooking School.
 */
@interface TCLesson : NSObject

/**
 * The unique ID of this lesson.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The name of this lesson.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The steps in this lesson. Each step is described by a 
 * \c TCLessonStep object.
 */
@property (nonatomic, copy, readonly) NSArray *steps;

/**
 * Initializes and returns a lesson with contents parsed from the given
 * XML data.
 *
 * @param xmlData The \c NSData object representing the XML data.
 *
 * @return An initialized \c TCLesson object.
 */
- (id)initWithXMLData:(NSData *)xmlData;

@end
