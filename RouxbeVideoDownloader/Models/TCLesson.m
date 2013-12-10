//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"
#import "TCStep.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Lesson's XML.
 */
static NSString * const TCLessonXMLPath = @"cooking-school/lessons/%lu.xml";

/**
 * The string template representing the relative path to a Lesson Step's video XML.
 */
static NSString * const TCLessonStepVideoXMLPath = @"embedded_player/settings_section/%ld.xml";

/**
 * The prototype of the block that will be called when a Lesson Step's
 * video URL request has completed.
 *
 * @param videoURL The URL to the video or \c nil on error.
 * @param error    The \c NSError object describing the error, if any.
 */
typedef void(^TCLessonStepVideoURLCompleteBlock)(NSURL *videoURL, NSError *error);

@interface TCStep (TCLesson)

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

#pragma mark -

@implementation TCLesson

+ (AFHTTPRequestOperation *)getLessonWithID:(NSUInteger)lessonID
                              completeBlock:(TCGroupCompleteBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];
    __weak typeof(service) weakService = service;

    return [service GET:[NSString stringWithFormat:TCLessonXMLPath, lessonID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCGroup *group = [[TCGroup alloc] initWithXMLData:data
                                             stepsXMLPath:@"recipesteps.recipestep"];

        // The most recent error encountered while fetching a video URL or
        // nil if everything went smoothly.
        NSError *__block videoURLError = nil;

        // Create a HTTP request operation for each lesson step's video URL that
        // we need to fetch.
        NSMutableArray *mutableOperations = [[NSMutableArray alloc] initWithCapacity:group.steps.count];
        for (TCStep *step in group.steps) {
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
                    completeBlock(group, nil);
                }
            }
        }];
        [weakService.operationQueue addOperations:operations waitUntilFinished:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error - Failed to fetch Lesson object.
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

@end

#pragma mark -

@implementation TCStep (TCLesson)

// Read and write video URL property is implemented by TCStep.
@dynamic videoURL;

- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompleteBlock:(TCLessonStepVideoURLCompleteBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];

    NSString *path = [NSString stringWithFormat:TCLessonStepVideoXMLPath, self.ID];
    NSMutableURLRequest *request = [service.requestSerializer requestWithMethod:@"GET"
                                                                      URLString:[[NSURL URLWithString:path relativeToURL:service.baseURL] absoluteString]
                                                                     parameters:nil];

    return [service HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, NSData *data) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
        NSString *urlString = [[rootXML child:@"video"] attribute:@"url"];
        self.videoURL = urlString ? [NSURL URLWithString:urlString] : nil;

        if (completeBlock) {
            completeBlock(self.videoURL, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

@end
