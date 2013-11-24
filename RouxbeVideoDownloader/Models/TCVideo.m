//
//  TCVideo.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCVideo.h"
#import "NSURL+RouxbeAdditions.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

@implementation TCVideo

@synthesize destinationPathComponent = _destinationPathComponent;

- (id)initWithSourceURL:(NSURL *)sourceURL
                  group:(NSString *)group
                  title:(NSString *)title
               position:(NSUInteger)position
{
    self = [super init];
    if (self) {
        _sourceURL = [sourceURL copy];
        _group = [group copy];
        _title = [title copy];
        _position = position;
    }
    return self;
}

- (id)initWithSourceURL:(NSURL *)sourceURL title:(NSString *)title
{
    return [self initWithSourceURL:sourceURL
                             group:nil
                             title:title
                          position:NSNotFound];
}

- (NSString *)destinationPathComponent
{
    if (!_destinationPathComponent) {
        // If video is part of a group it will be saved to a directory with
        // the same name as the group. Otherwise, it will just be saved as
        // its title.
        if (self.group) {
            NSString *fileName = [[NSString alloc] initWithFormat:
                                  @"%02lu - %@.mp4", self.position + 1, self.title];
            _destinationPathComponent = [self.group stringByAppendingPathComponent:fileName];
        } else {
            _destinationPathComponent = [[NSString alloc] initWithFormat:
                                         @"%@.mp4", self.title];
        }
    }
    return _destinationPathComponent;
}

+ (void)videosWithURL:(NSURL *)aURL
    completionHandler:(TCVideoSearchCompletionHandler)completionHandler
{
    NSParameterAssert(aURL);

    switch ([aURL rouxbeCategory]) {
        case TCRouxbeCategoryLesson:
            [self videosWithLessonURL:aURL
                    completionHandler:completionHandler];
            break;

        case TCRouxbeCategoryRecipe:
            break;

        case TCRouxbeCategoryTip:
            break;

        default: {
            // Error - Unknown Category
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorBadURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"Unknown Rouxbe Category",
                                                               NSLocalizedRecoverySuggestionErrorKey: [NSString stringWithFormat:@"Unknown Category for URL: %@", [aURL absoluteString]]}];
            completionHandler(nil, error);
            break;
        }
    }
}

#pragma mark - Lesson Videos

+ (void)videosWithLessonURL:(NSURL *)lessonURL
          completionHandler:(TCVideoSearchCompletionHandler)completionHandler
{
    [TCLesson lessonWithID:[lessonURL rouxbeID] completionHandler:^(TCLesson *lesson, NSError *error) {
        if (lesson) {
            NSMutableArray *videos = [[NSMutableArray alloc] initWithCapacity:lesson.steps.count];

            // Create a video for each Lesson's step.
            for (TCLessonStep *step in lesson.steps) {
                TCVideo *video = [[TCVideo alloc] initWithSourceURL:step.videoURL
                                                              group:step.lessonName
                                                              title:step.name
                                                           position:step.position];
                [videos addObject:video];
            }            
            completionHandler(videos, nil);
        } else {
            // Error - Failed to fetch Lesson.
            completionHandler(nil, error);
        }
    }];
}

@end
