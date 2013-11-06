//
//  TCLessonStep.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCLessonStep object describes a step in a lesson. A lesson consists of
 * one or more steps.
 */
@interface TCLessonStep : NSObject

/**
 * The unique ID of this lesson step.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The position of this lesson step, with \c 0 being the first position,
 * \c 1 being the second position, etc...
 */
@property (nonatomic, assign, readonly) NSUInteger position;

/**
 * The name of this lesson step.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * Initializes the lesson step's properties with data parsed from the 
 * given XML element.
 *
 * @param xmlElement The \c RXMLElement object representing the lesson's 
 *                   step XML element.
 *
 * @return An initialized \c TCLessonStep object.
 */
- (id)initWithXMLElement:(RXMLElement *)xmlElement;

/**
 * Finds and returns the URL of this lesson step's video.
 *
 * @param completion The completion block will be called when the video URL has 
 *                   been found or an error was encountered.
 */
- (void)findVideoURLWithCompletion:(void (^)(NSURL *videoURL, NSError *error))completion;

@end
