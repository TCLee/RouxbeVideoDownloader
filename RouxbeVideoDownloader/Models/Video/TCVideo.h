//
//  TCVideo.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/20/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * The prototype of the block that will be called when the videos have 
 * been found or an error was encountered.
 *
 * @param videos The array of videos found or \c nil on error.
 * @param error  The \c NSError object describing the error or \c nil on success.
 */
typedef void(^TCVideoCompleteBlock)(NSArray *videos, NSError *error);

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

/**
 * Returns an initialized video that does not belong to a group.
 *
 * If video belongs to a group, use TCVideo::initWithSourceURL:group:title:position:
 * instead.
 *
 * @param sourceURL The URL to this video.
 * @param title     The title of this video.
 */
- (id)initWithSourceURL:(NSURL *)sourceURL
                  title:(NSString *)title;

/**
 * Returns an initialized video that belongs to the given group.
 *
 * If video does not belong to a group, use TCVideo::initWithSourceURL:title:
 * instead.
 *
 * @param sourceURL The URL to this video.
 * @param group     The group that this video belongs to.
 * @param title     The title of this video.
 * @param position  The position of this video in a group.
 */
- (id)initWithSourceURL:(NSURL *)sourceURL
                  group:(NSString *)group
                  title:(NSString *)title
               position:(NSUInteger)position;

/**
 * Find all videos from the given URL. The completion handler will be called 
 * when the videos are found or an error occured during the search.
 *
 * @param aURL           The URL to search for videos.
 * @param completeBlock  The completion handler to call when the videos are
 *                       found or an error occured.
 *
 * @return An \c AFHTTPRequestOperation with a \c GET request.
 */
+ (AFHTTPRequestOperation *)getVideosFromURL:(NSURL *)aURL
                               completeBlock:(TCVideoCompleteBlock)completionHandler;

@end
