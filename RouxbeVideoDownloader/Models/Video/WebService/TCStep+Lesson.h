//
//  TCStep+Lesson.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCStep.h"

/**
 * The prototype of the block that will be called when a Lesson Step's
 * video URL request has completed.
 *
 * @param videoURL The URL to the video or \c nil on error.
 * @param error    The \c NSError object describing the error, if any.
 */
typedef void(^TCLessonStepVideoURLCompleteBlock)(NSURL *videoURL, NSError *error);

@interface TCStep (Lesson)

@property (readwrite, nonatomic, copy) NSURL *videoURL;

/**
 * Creates an \c AFHTTPRequestOperation with a \c GET request to
 * fetch the Lesson Step's video URL.
 *
 * @param completeBlock The completion handler to call when the video
 *                      URL is fetched or there is an error.
 *
 * @return An \c AFHTTPRequestOperation object with a \c GET request
 */
- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompleteBlock:(TCLessonStepVideoURLCompleteBlock)completeBlock;

@end
