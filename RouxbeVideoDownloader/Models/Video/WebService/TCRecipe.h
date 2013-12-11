//
//  TCRecipe.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCGroup.h"

/**
 * \c TCRecipe class describes a recipe from Rouxbe Cooking School.
 */
@interface TCRecipe : NSObject

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
                              completeBlock:(TCGroupCompleteBlock)completeBlock;

@end
