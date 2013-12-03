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
static NSString * const TCLessonXMLPath = @"cooking-school/lessons/%lu.xml";

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
//+ (void)fetchVideoURLsForLesson:(TCLesson *)lesson
//              completionHandler:(TCLessonCompletionHandler)completionHandler;

@end

@implementation TCLesson

#pragma mark - Fetch Lesson Object

+ (AFHTTPRequestOperation *)getLessonWithID:(NSUInteger)lessonID
                              completeBlock:(TCLessonCompleteBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];
    __weak typeof(service) weakService = service;

    return [service GET:[NSString stringWithFormat:TCLessonXMLPath, lessonID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCLesson *lesson = [[TCLesson alloc] initWithXMLData:data];

        // The most recent error encountered while fetching a video URL or
        // nil if everything went smoothly.
        NSError *__block videoURLError = nil;

        // Create a HTTP request operation for each lesson step's video URL that
        // we need to fetch.
        NSMutableArray *mutableOperations = [[NSMutableArray alloc] initWithCapacity:lesson.steps.count];
        for (TCLessonStep *step in lesson.steps) {
            // Skip lesson steps that already have a video URL.
            if (step.videoURL) { continue; }

            AFHTTPRequestOperation *operation = [step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
                if (error) {
                    videoURLError = error;

                    // Fail to fetch one of the lesson step's video URL, so
                    // we cancel all remaining request operations.
                    [mutableOperations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *requestOperation, NSUInteger index, BOOL *stop) {
                        [requestOperation cancel];
                    }];
                }
            }];
            [mutableOperations addObject:operation];
        }

        // Execute the HTTP request operations as a single batch.
        // The completion block will only be called when all the request
        // operations have completed or when any one of the request operation
        // encountered an error.
        NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock:nil completionBlock:^(NSArray *operations) {
            if (completeBlock) {
                if (videoURLError) {
                    completeBlock(nil, videoURLError);
                } else {
                    completeBlock(lesson, nil);
                }
            }
        }];
        [weakService.operationQueue addOperations:operations waitUntilFinished:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error - Failed to fetch Lesson object.
        if (completeBlock) {
            completeBlock(nil, [self lessonErrorWithUnderlyingError:error]);
        }
    }];
}

/**
 * Returns a more detailed error object specific to the Lesson object.
 */
+ (NSError *)lessonErrorWithUnderlyingError:(NSError *)error
{
    NSMutableDictionary *mutableUserInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];
    mutableUserInfo[NSLocalizedDescriptionKey] = [[NSString alloc] initWithFormat:
                                                  @"Lesson XML: %@\n"
                                                  "Error: %@",
                                                  error.userInfo[NSURLErrorFailingURLStringErrorKey],
                                                  error.localizedDescription];

    return [[NSError alloc] initWithDomain:error.domain
                                      code:error.code
                                  userInfo:[mutableUserInfo copy]];
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
