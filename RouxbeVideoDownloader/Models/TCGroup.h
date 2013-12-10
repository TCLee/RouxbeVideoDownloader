//
//  TCGroup.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCGroup;

/**
 * The prototype of the block that will be called when a group request
 * has completed.
 *
 * @param group The group object created from the response or \c nil on failure.
 * @param error The \c NSError object describing the error or \c nil on success.
 */
typedef void(^TCGroupCompleteBlock)(TCGroup *group, NSError *error);

/**
 * \c TCGroup class describes a Rouxbe grouped content. 
 *
 * For example, a Lesson or Recipe consists of one or more Steps.
 */
@interface TCGroup : NSObject

/**
 * The unique ID of this group.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The name of this group.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The steps in this group. Each step is described by a
 * \c TCStep object.
 */
@property (nonatomic, copy, readonly) NSArray *steps;

/**
 * Initializes a new group object from the given XML data.
 *
 * @param data         The XML data.
 * @param stepsXMLPath The path to the array of step elements in the XML.
 */
- (id)initWithXMLData:(NSData *)data
         stepsXMLPath:(NSString *)stepsXMLPath;

@end
