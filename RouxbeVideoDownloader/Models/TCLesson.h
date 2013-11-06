//
//  TCLesson.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

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
 * Initializes the lesson's properties with data parsed from the 
 * given XML element.
 *
 * @param element The \c RXMLElement object representing the lesson XML element.
 *
 * @return An initialized \c TCLesson object.
 */
- (id)initWithXMLElement:(RXMLElement *)element;

@end
