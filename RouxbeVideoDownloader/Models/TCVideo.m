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
#import "TCRecipe.h"
#import "TCRecipeStep.h"

#pragma mark Flash to MP4 Video URL

/**
 * URL to get the MP4 version of the video rather than the default Flash video.
 * Downloading the video in MP4 makes it compatible with iOS devices.
 */
static NSString * const kMP4VideoURLString = @"http://media.rouxbe.com/itouch/mp4/%@.mp4";

FOUNDATION_STATIC_INLINE NSURL *MP4VideoURLFromFlashVideoURL(NSURL *flashVideoURL)
{
    if (!flashVideoURL) { return nil; }

    // Delete the ".f4v" (Flash) file extension. We just want the file name only.
    NSString *videoName = [[flashVideoURL lastPathComponent] stringByDeletingPathExtension];

    // Create the URL from the template string and return the URL to the MP4 video.
    return [NSURL URLWithString:[NSString stringWithFormat:kMP4VideoURLString, videoName]];
}

@implementation TCVideo

@synthesize destinationPathComponent = _destinationPathComponent;

#pragma mark - Initialize

- (id)initWithSourceURL:(NSURL *)sourceURL
                  group:(NSString *)group
                  title:(NSString *)title
               position:(NSUInteger)position
{
    self = [super init];
    if (self) {
        _sourceURL = MP4VideoURLFromFlashVideoURL(sourceURL);
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

#pragma mark - Destination Path Component

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

#pragma mark - Find Videos from URL

+ (void)findVideosFromURL:(NSURL *)aURL
            completeBlock:(TCVideoCompleteBlock)completeBlock
{
    NSParameterAssert(aURL);

    // Determine the resource category from the URL.
    switch ([aURL rouxbeCategory]) {
        case TCRouxbeCategoryLesson:
            [self findVideosFromLessonURL:aURL completeBlock:completeBlock];
            break;

        case TCRouxbeCategoryRecipe:
            [self findVideosFromRecipeURL:aURL completeBlock:completeBlock];
            break;

        case TCRouxbeCategoryTip:
            break;

        case TCRouxbeCategoryUnknown:
        default: {
            // Error - Invalid Rouxbe URL
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorUnsupportedURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Examples of valid rouxbe.com URL:\n- http://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock\n- http://rouxbe.com/recipes/63-red-pepper-eggplant-confit"}];
            if (completeBlock) {
                completeBlock(nil, error);
            }
            break;
        }
    }
}

+ (void)findVideosFromLessonURL:(NSURL *)lessonURL
                  completeBlock:(TCVideoCompleteBlock)completeBlock
{
    [TCLesson getLessonWithID:[lessonURL rouxbeID] completeBlock:^(TCLesson *lesson, NSError *error) {
        NSMutableArray *mutableVideos = nil;
        if (lesson) {
            // Create a video for each Lesson's step.
            mutableVideos = [[NSMutableArray alloc] initWithCapacity:lesson.steps.count];
            for (TCLessonStep *step in lesson.steps) {
                TCVideo *video = [[TCVideo alloc] initWithSourceURL:step.videoURL
                                                              group:step.lessonName
                                                              title:step.name
                                                           position:step.position];
                [mutableVideos addObject:video];
            }
        }

        if (completeBlock) {
            completeBlock(mutableVideos, error);
        }
    }];
}

+ (void)findVideosFromRecipeURL:(NSURL *)recipeURL
                  completeBlock:(TCVideoCompleteBlock)completeBlock
{
    [TCRecipe getRecipeWithID:[recipeURL rouxbeID] completeBlock:^(TCRecipe *recipe, NSError *error) {
        NSMutableArray *mutableVideos = nil;
        if (recipe) {
            mutableVideos = [[NSMutableArray alloc] initWithCapacity:recipe.steps.count];
            for (TCRecipeStep *step in recipe.steps) {
                TCVideo *video = [[TCVideo alloc] initWithSourceURL:step.videoURL
                                                              group:step.recipeName
                                                              title:step.name
                                                           position:step.position];
                [mutableVideos addObject:video];
            }
        }

        if (completeBlock) {
            completeBlock(mutableVideos, error);
        }
    }];
}

@end
