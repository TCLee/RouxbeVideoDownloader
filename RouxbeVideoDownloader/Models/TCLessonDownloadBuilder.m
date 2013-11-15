//
//  TCLessonDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/13/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonDownloadBuilder.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

#import "TCDownload.h"
#import "NSURL+RouxbeAdditions.h"

@interface TCLessonDownloadBuilder ()

/**
 * Creates and returns a \c TCDownload object initialized from the
 * given \c TCLessonStep object.
 *
 * @param step The \c TCLessonStep object describing a lesson's step.
 *
 * @return A \c TCDownload object initialized from the given \c TCLessonStep object.
 */
+ (TCDownload *)downloadWithLessonStep:(TCLessonStep *)step;

@end

@implementation TCLessonDownloadBuilder

+ (void)createDownloadsWithURL:(NSURL *)aURL handler:(TCDownloadBuilderBlock)handler
{
    [TCLesson lessonWithID:[aURL rouxbeID] completionHandler:^(TCLesson *lesson, NSError *error) {
        // Error - Failed to fetch Lesson object. Cannot create downloads.
        if (!lesson) {
            handler(nil, error);
            return;
        }

        // Create a download for each step in the lesson.
        for (TCLessonStep *step in lesson.steps) {
            // We may have to fetch the lesson step's video URL from another
            // source because not all lesson step may include a video URL.
            [step videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {
                handler([self downloadWithLessonStep:step], error);
            }];
        }
    }];
}

+ (TCDownload *)downloadWithLessonStep:(TCLessonStep *)step
{
    TCDownload *download = [[TCDownload alloc] initWithSourceURL:step.videoURL
                                                       groupName:step.lessonName
                                                        position:step.position
                                                            name:step.name];
    return download;
}

@end
