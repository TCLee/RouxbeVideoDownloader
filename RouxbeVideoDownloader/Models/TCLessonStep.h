//
//  TCLessonStep.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * The block that will be called when a lesson step's video URL 
 * request has completed.
 *
 * @param videoURL The URL to the video or \c nil on error.
 * @param error    The \c NSError object describing the error, if any.
 */
typedef void(^TCLessonStepVideoURLBlock)(NSURL *videoURL, NSError *error);

/**
 * \c TCLessonStep object describes a step in a lesson. A lesson consists of
 * one or more steps.
 */
@interface TCLessonStep : NSObject

/**
 * The name of the lesson that this step belongs to.
 */
@property (nonatomic, copy, readonly) NSString *lessonName;

/**
 * The unique ID of this lesson step.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The zero-based position of this lesson step.
 */
@property (nonatomic, assign, readonly) NSUInteger position;

/**
 * The name of this lesson step.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The URL to this lesson step's video.
 *
 * The video URL may return \c nil, if the video URL has not been fetched
 * yet with a call to TCLesson::videoURLWithCompletionHandler:
 */
@property (nonatomic, copy, readonly) NSURL *videoURL;

/**
 * Initializes a new lesson step object from the given XML.
 *
 * @param stepXML    The XML representing a lesson step element.
 * @param lessonName The name of the lesson that this step belongs to.
 *
 * @return A new \c TCLessonStep object with properties initialized 
 *         from the XML.
 */
- (id)initWithXML:(RXMLElement *)stepXML
       lessonName:(NSString *)lessonName;

/**
 * Creates an \c AFHTTPRequestOperation object that will fetch the lesson 
 * step's video URL.
 *
 * @param completionHandler The completion handler to call when the video
 *                          URL is fetched or there is an error.
 */
- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompletionHandler:(TCLessonStepVideoURLBlock)completionHandler;

@end
