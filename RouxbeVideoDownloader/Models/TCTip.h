//
//  TCTip.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/11/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

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

@end
