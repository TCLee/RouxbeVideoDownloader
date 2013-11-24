//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"
#import "TCLessonStep.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the URL to a Lesson's XML.
 */
static NSString * const TCRouxbeLessonXMLPath = @"cooking-school/lessons/%lu.xml";

@interface TCLesson ()

/**
 * Fetches the video URL for each of the given lesson's step. Calls
 * the completion handler when all the video URLs have been fetched
 * or an error occured.
 *
 * @param lesson            The lesson's steps to fetch the video URLs for.
 * @param completionHandler A block object to be called when the request is done
 *                          or an error occured.
 */
+ (void)fetchVideoURLsForLesson:(TCLesson *)lesson
              completionHandler:(TCLessonCompletionHandler)completionHandler;

@end

@implementation TCLesson

#pragma mark - Class Methods

+ (NSURLSessionDataTask *)lessonWithID:(NSUInteger)lessonID
                     completionHandler:(TCLessonCompletionHandler)completionHandler;
{
    return [[TCRouxbeService sharedService] getXML:[NSString stringWithFormat:TCRouxbeLessonXMLPath, lessonID] success:^(NSURLSessionDataTask *task, NSData *data) {
        TCLesson *lesson = [[TCLesson alloc] initWithXMLData:data];
        [self fetchVideoURLsForLesson:lesson completionHandler:completionHandler];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // Error - Failed to fetch Lesson object.
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];
}

+ (void)fetchVideoURLsForLesson:(TCLesson *)lesson
              completionHandler:(TCLessonCompletionHandler)completionHandler
{
    NSMutableArray *runningDataTasks = [[NSMutableArray alloc] init];
    NSMutableArray *stepsWithoutVideoURL = [lesson.steps mutableCopy];

    for (TCLessonStep *step in lesson.steps) {
        // If step already has a video URL, then we can skip that step.
        if (step.videoURL) {
            [stepsWithoutVideoURL removeObjectIdenticalTo:step];
            continue;
        }

        // Must use the __block storage type because we're using the dataTask
        // variable inside the block before it's initialized.
        // See Also: http://www.friday.com/bbum/2009/08/29/blocks-tips-tricks/ [Section: 7) Recursive Block]

        __block NSURLSessionDataTask *dataTask = [step videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {
            // This data task has completed, so remove it from the list.
            [runningDataTasks removeObjectIdenticalTo:dataTask];

            if (videoURL) {
                // This step has a video URL now, so remove it from the list.
                [stepsWithoutVideoURL removeObjectIdenticalTo:step];

                // When all steps have a video URL, we can callback with the result.
                if (0 == stepsWithoutVideoURL.count) {
                    if (completionHandler) {
                        completionHandler(lesson, nil);
                    }
                }
            } else {
                // If one of the Lesson's step video URL could not be
                // retrieved, we consider the entire Lesson request as failed.

                // Cancels all remaining running tasks.
                [runningDataTasks enumerateObjectsUsingBlock:^(NSURLSessionDataTask *dataTask, NSUInteger index, BOOL *stop) {
                    [dataTask cancel];
                }];

                if (completionHandler) {
                    completionHandler(nil, error);
                }
            }
        }];
        [runningDataTasks addObject:dataTask];
    }
}

#pragma mark - Instance Methods

- (id)initWithXMLData:(NSData *)data
{
    // If XML data is not provided, we can't create a Lesson object.
    if (!data) { return nil; }

    self = [super init];
    if (self) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        _ID = [[rootXML attribute:@"id"] integerValue];
        _name = [rootXML attribute:@"name"];
        _steps = [self stepsWithXML:rootXML];
    }
    return self;
}

- (NSArray *)stepsWithXML:(RXMLElement *)rootXML
{
    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];

    // Create a TCLessonStep object from each step XML element.
    [rootXML iterate:@"recipesteps.recipestep" usingBlock:^(RXMLElement *stepXML) {
        TCLessonStep *step = [[TCLessonStep alloc] initWithXML:stepXML
                                                    lessonName:self.name];
        [mutableSteps addObject:step];
    }];

    return [mutableSteps copy];
}

@end
