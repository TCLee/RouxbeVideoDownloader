//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"
#import "TCStep+Lesson.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Lesson's XML.
 */
static NSString * const TCLessonXMLPath = @"cooking-school/lessons/%lu.xml";

@implementation TCLesson

+ (AFHTTPRequestOperation *)getLessonWithID:(NSUInteger)lessonID
                              completeBlock:(TCGroupCompleteBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];
    __weak typeof(service) weakService = service;

    return [service GET:[NSString stringWithFormat:TCLessonXMLPath, lessonID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCGroup *lesson = [[TCGroup alloc] initWithXMLData:data
                                             stepsXMLPath:@"recipesteps.recipestep"];

        NSArray *batchedOperations = [AFURLConnectionOperation batchOfRequestOperations:[self videoURLRequestOperationsForSteps:lesson.steps] progressBlock:nil completionBlock:^(NSArray *operations) {
            if (completeBlock) {
                AFHTTPRequestOperation *failedOperation = [self failedOperationInOperations:operations];
                if (failedOperation) {
                    // If one of the request operation in the batch failed, we
                    // consider the entire batch as failed. This is to prevent
                    // returning an incomplete Lesson object.
                    completeBlock(nil, failedOperation.error);
                } else {
                    completeBlock(lesson, nil);
                }
            }
        }];
        [weakService.operationQueue addOperations:batchedOperations waitUntilFinished:NO];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Error - Failed to fetch Lesson object.
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

/**
 * Creates an \c AFHTTPRequestOperation for each Lesson Step's video URL and
 * returns the array of \c AFHTTPRequestOperation objects.
 *
 * @param steps The steps in a lesson.
 */
+ (NSArray *)videoURLRequestOperationsForSteps:(NSArray *)steps
{
    NSMutableArray *mutableOperations = [[NSMutableArray alloc] initWithCapacity:steps.count];

    // Create a request operation for each Lesson's Step that is missing
    // a video URL.
    for (TCStep *step in steps) {
        if (step.videoURL) { continue; }

        AFHTTPRequestOperation *requestOperation = [step videoURLRequestOperationWithCompleteBlock:^(NSURL *videoURL, NSError *error) {
            if (error) {
                // If one of the request operation in the batch failed, we consider
                // the whole batch as failed. So, when we receive an error callback
                // we cancel all remaining request operations in the batch.
                [mutableOperations enumerateObjectsUsingBlock:^(AFHTTPRequestOperation *operation, NSUInteger index, BOOL *stop) {
                    [operation cancel];
                }];
            }
        }];
        [mutableOperations addObject:requestOperation];
    }

    return mutableOperations;
}

/**
 * Returns the first failed request operation in the given array 
 * of operations. Returns \c nil, if all operations are successful.
 *
 * @param operations The array of \c AFHTTPRequestOperation objects.
 */
+ (AFHTTPRequestOperation *)failedOperationInOperations:(NSArray *)operations
{
    NSUInteger errorIndex = [operations indexOfObjectPassingTest:^BOOL(AFHTTPRequestOperation *operation, NSUInteger index, BOOL *stop) {
        return nil != operation.error;
    }];

    return NSNotFound == errorIndex ? nil : operations[errorIndex];
}

@end

