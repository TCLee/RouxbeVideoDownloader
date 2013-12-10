//
//  TCRecipe.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCRecipe.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Recipe's XML.
 */
static NSString * const TCRecipeXMLPath = @"recipes/%lu.xml";

@implementation TCRecipe

+ (AFHTTPRequestOperation *)getRecipeWithID:(NSUInteger)recipeID
                              completeBlock:(TCGroupCompleteBlock)completeBlock
{
    return [[TCRouxbeService sharedService] GET:[NSString stringWithFormat:TCRecipeXMLPath, recipeID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCGroup *recipe = [[TCGroup alloc] initWithXMLData:data
                                              stepsXMLPath:@"recipeSteps.recipeStep"];
        if (completeBlock) {
            completeBlock(recipe, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

@end
