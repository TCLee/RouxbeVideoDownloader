//
//  TCVideo.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCVideo.h"
#import "NSURL+RouxbeAdditions.h"
#import "TCGroup.h"
#import "TCStep.h"
#import "TCLesson.h"
#import "TCRecipe.h"
#import "TCTip.h"


#pragma mark Flash to MP4 Video URL

/**
 * URL to get the MP4 version of the video rather than the default Flash video.
 * Downloading the video in MP4 makes it compatible with iOS devices.
 */
static NSString * const TCMP4VideoURLString = @"http://media.rouxbe.com/itouch/mp4/%@.mp4";

@implementation TCVideo

@synthesize destinationPathComponent = _destinationPathComponent;

#pragma mark - Initialize

- (id)initWithSourceURL:(NSURL *)sourceURL
                  group:(NSString *)group
                  title:(NSString *)title
               position:(NSUInteger)position
{
    NSParameterAssert(sourceURL);
    NSParameterAssert(title);

    self = [super init];
    if (self) {
        _sourceURL = [[self class] MP4VideoURLFromFlashVideoURL:sourceURL];
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

/**
 * Returns a URL to the MP4 version of the video from the given Flash video URL.
 *
 * @param flashVideoURL The URL to the Flash version of the video.
 */
+ (NSURL *)MP4VideoURLFromFlashVideoURL:(NSURL *)flashVideoURL
{
    if (!flashVideoURL) { return nil; }

    // Delete the ".f4v" (Flash) file extension. We just want the file name only.
    NSString *videoName = [[flashVideoURL lastPathComponent] stringByDeletingPathExtension];

    // Create the URL from the template string and return the URL to the MP4 video.
    return [NSURL URLWithString:[NSString stringWithFormat:TCMP4VideoURLString, videoName]];
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

+ (AFHTTPRequestOperation *)getVideosFromURL:(NSURL *)theURL
                               completeBlock:(TCVideoCompleteBlock)completeBlock
{
    NSParameterAssert(theURL);

    switch ([theURL rouxbeCategory]) {
        case TCRouxbeCategoryLesson:
            return [TCLesson getLessonWithID:[theURL rouxbeID] completeBlock:^(TCGroup *group, NSError *error) {
                if (completeBlock) {
                    completeBlock([self videosFromGroup:group], error);
                }
            }];

        case TCRouxbeCategoryRecipe:
            return [TCRecipe getRecipeWithID:[theURL rouxbeID] completeBlock:^(TCGroup *group, NSError *error) {
                if (completeBlock) {
                    completeBlock([self videosFromGroup:group], error);
                }
            }];

        case TCRouxbeCategoryTip:
            return [TCTip getTipWithID:[theURL rouxbeID] completeBlock:^(TCTip *tip, NSError *error) {
                if (completeBlock) {
                    completeBlock([self videosFromTip:tip], error);
                }
            }];

        case TCRouxbeCategoryUnknown:
        default: {
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorUnsupportedURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Examples of valid rouxbe.com URL:\n- http://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock\n- http://rouxbe.com/recipes/63-red-pepper-eggplant-confit"}];
            if (completeBlock) {
                completeBlock(nil, error);
            }
            return nil;
        }
    }
}

/**
 * Returns an array of video objects from the given group object.
 * Each video will represent one step from the group.
 */
+ (NSArray *)videosFromGroup:(TCGroup *)group
{
    if (!group) { return nil; }

    NSMutableArray *mutableVideos = [[NSMutableArray alloc] initWithCapacity:group.steps.count];
    for (TCStep *step in group.steps) {
        TCVideo *video = [[TCVideo alloc] initWithSourceURL:step.videoURL
                                                      group:step.groupName
                                                      title:step.name
                                                   position:step.position];
        [mutableVideos addObject:video];
    }
    return mutableVideos;
}

/**
 * Returns an array with one video object from the given tip object.
 */
+ (NSArray *)videosFromTip:(TCTip *)tip
{
    if (!tip) { return nil; }

    TCVideo *video = [[TCVideo alloc] initWithSourceURL:tip.videoURL
                                                  title:tip.name];
    return @[video];
}

@end
