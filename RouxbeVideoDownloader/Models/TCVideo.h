//
//  TCVideo.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCVideo;

typedef void(^TCVideoSearchCompletionHandler)(NSArray *videos, NSError *error);

/**
 * \c TCVideo class describes a Rouxbe video resource.
 */
@interface TCVideo : NSObject

/**
 * The group that this video belongs to or \c nil if video 
 * is not part of a group.
 */
@property (nonatomic, copy, readonly) NSString *group;

/**
 * The title of this video.
 */
@property (nonatomic, copy, readonly) NSString *title;

/**
 * The position of this video in a group.
 *
 * The position returns \c NSNotFound, if video is not part of a group.
 */
@property (nonatomic, assign, readonly) NSUInteger position;

/**
 * The URL of this video.
 */
@property (nonatomic, copy, readonly) NSURL *sourceURL;

/**
 * The component of the path where the video file should be saved to.
 *
 * This string should be appended to a directory of the user's
 * choosing to form the full file path to the destination.
 */
@property (nonatomic, copy, readonly) NSString *destinationPathComponent;

- (id)initWithSourceURL:(NSURL *)sourceURL
                  title:(NSString *)title;

/**
 * <#Description#>
 *
 * @param sourceURL <#sourceURL description#>
 * @param group     <#group description#>
 * @param title     <#title description#>
 * @param position  <#position description#>
 *
 * @return <#return value description#>
 */
- (id)initWithSourceURL:(NSURL *)sourceURL
                  group:(NSString *)group
                  title:(NSString *)title
               position:(NSUInteger)position;

/**
 * Find all videos from the given URL. The completion handler will be called 
 * when the videos are found or an error occured during the search.
 *
 * @param aURL              The URL to search for videos.
 * @param completionHandler The completion handler to call when the videos are
 *                          found or an error occured.
 */
+ (void)videosWithURL:(NSURL *)aURL
    completionHandler:(TCVideoSearchCompletionHandler)completionHandler;

@end
