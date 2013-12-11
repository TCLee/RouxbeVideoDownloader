//
//  TCStep.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCStep object describes a step in a group. A group consists of
 * one or more steps.
 */
@interface TCStep : NSObject

/**
 * The name of the group that this step belongs to.
 */
@property (nonatomic, copy, readonly) NSString *groupName;

/**
 * The unique ID of this step.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The zero-based position of this step.
 */
@property (nonatomic, assign, readonly) NSUInteger position;

/**
 * The name of this step.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The URL to this step's video.
 */
@property (nonatomic, copy, readonly) NSURL *videoURL;

/**
 * Initializes a new step object from the given XML element.
 *
 * @param stepXML    The XML representing a step element.
 * @param recipeName The name of the group that this step belongs to.
 */
- (id)initWithXML:(RXMLElement *)stepXML groupName:(NSString *)groupName;

@end
