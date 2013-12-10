//
//  TCRecipeStep.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCRecipeStep object describes a step in a recipe. A recipe consists of
 * one or more steps.
 */
@interface TCRecipeStep : NSObject

/**
 * The name of the recipe that this step belongs to.
 */
@property (nonatomic, copy, readonly) NSString *recipeName;

/**
 * The unique ID of this recipe step.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The zero-based position of this recipe step.
 */
@property (nonatomic, assign, readonly) NSUInteger position;

/**
 * The name of this recipe step.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The URL to this recipe step's video.
 */
@property (nonatomic, copy, readonly) NSURL *videoURL;

/**
 * The URL to this recipe step's image.
 */
@property (nonatomic, copy, readonly) NSURL *imageURL;

/**
 * Initializes a new recipe step object from the given XML element.
 *
 * @param stepXML    The XML representing a recipe step element.
 * @param recipeName The name of the recipe that this step belongs to.
 */
- (id)initWithXML:(RXMLElement *)stepXML
       recipeName:(NSString *)recipeName;

@end
