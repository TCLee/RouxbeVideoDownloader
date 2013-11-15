//
//  TCLesson.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCLesson;

/**
 * The block that will be called when a lesson request has 
 * completed.
 *
 * @param lesson The \c TCLesson object that is returned from the 
 *               response or \c nil on error.
 * @param error  A \c NSError object describing the error, if any.
 */
typedef void(^TCLessonBlock)(TCLesson *lesson, NSError *error);

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
 * Fetches a Lesson with the given ID and calls the completion 
 * handler when request is done.
 *
 * @param lessonID          The unique ID of the lesson.
 * @param completionHandler The handler to be called when request is done.
 */
+ (void)lessonWithID:(NSUInteger)lessonID
   completionHandler:(TCLessonBlock)completionHandler;

/**
 * Initializes a new lesson object from the given XML data.
 *
 * @param data The XML data.
 *
 * @return A new \c TCLesson object with properties initialized 
 *         from the XML data.
 */
- (id)initWithXMLData:(NSData *)data;

@end
