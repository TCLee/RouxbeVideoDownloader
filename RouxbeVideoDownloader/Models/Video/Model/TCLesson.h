//
//  TCLesson.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCGroup.h"

/**
 * \c TCLesson object describes a lesson in Rouxbe's Cooking School.
 */
@interface TCLesson : NSObject

/**
 * Creates and runs an \c AFHTTPRequestOperation to fetch a lesson with
 * the given ID. The completion block will be called when request is done.
 *
 * @param lessonID       The unique ID of the lesson.
 * @param completeBlock  The block object to be called when request is done.
 *
 * @return An \c AFHTTPRequestOperation object with a \c GET request.
 */
+ (AFHTTPRequestOperation *)getLessonWithID:(NSUInteger)lessonID
                              completeBlock:(TCGroupCompleteBlock)completeBlock;

@end
