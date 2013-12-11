//
//  TCTip.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/11/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCTip;

/**
 * The prototype of the block that will be called when a tip request
 * has completed.
 *
 * @param tip   The tip object created from the response or \c nil on failure.
 * @param error The \c NSError object describing the error or \c nil on success.
 */
typedef void(^TCTipCompleteBlock)(TCTip *tip, NSError *error);

/**
 * \c TCTip model class describes a Rouxbe Tip & Technique content.
 */
@interface TCTip : NSObject

/**
 * The unique ID of this Tip & Technique content.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The name of this Tip & Technique content.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The URL to this Tip & Technique content's video.
 */
@property (nonatomic, copy, readonly) NSURL *videoURL;

/**
 * Creates and runs an \c AFHTTPRequestOperation to fetch a tip with
 * the given ID. The completion block will be called when request is done.
 *
 * @param recipeID       The unique ID of the tip.
 * @param completeBlock  The block object to be called when request is done.
 *
 * @return An \c AFHTTPRequestOperation object with a \c GET request.
 */
+ (AFHTTPRequestOperation *)getTipWithID:(NSUInteger)tipID
                           completeBlock:(TCTipCompleteBlock)completeBlock;

/**
 * Initializes a new tip object from the given XML data.
 *
 * @param data The XML data.
 */
- (id)initWithXMLData:(NSData *)data;

@end
