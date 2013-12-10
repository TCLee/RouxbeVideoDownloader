//
//  TCRecipe.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCRecipe;

/**
 * The prototype of the block that will be called when a recipe request 
 * is done.
 *
 * @param recipe The recipe object created from the response or \c nil on failure.
 * @param error  The \c NSError object describing the error or \c nil on success.
 */
typedef void(^TCRecipeCompleteBlock)(TCRecipe *recipe, NSError *error);

/**
 * \c TCRecipe class describes a recipe from Rouxbe Cooking School.
 */
@interface TCRecipe : NSObject

/**
 * The unique ID of this recipe.
 */
@property (nonatomic, assign, readonly) NSUInteger ID;

/**
 * The name of this recipe.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The steps in this recipe. Each step is described by a
 * \c TCRecipeStep object.
 */
@property (nonatomic, copy, readonly) NSArray *steps;

/**
 * Initializes a new recipe object from the given XML data.
 *
 * @param data The XML data.
 */
- (id)initWithXMLData:(NSData *)data;

/**
 * Creates and runs an \c AFHTTPRequestOperation to fetch a recipe with
 * the given ID. The completion block will be called when request is done.
 *
 * @param recipeID       The unique ID of the recipe.
 * @param completeBlock  The block object to be called when request is done.
 *
 * @return An \c AFHTTPRequestOperation object with a \c GET request.
 */
+ (AFHTTPRequestOperation *)getRecipeWithID:(NSUInteger)recipeID
                              completeBlock:(TCRecipeCompleteBlock)completeBlock;

@end
