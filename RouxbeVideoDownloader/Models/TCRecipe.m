//
//  TCRecipe.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCRecipe.h"
#import "TCRecipeStep.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Recipe's XML.
 */
static NSString * const TCRecipeXMLPath = @"recipes/%lu.xml";

@implementation TCRecipe

#pragma mark - Fetch Recipe

+ (AFHTTPRequestOperation *)getRecipeWithID:(NSUInteger)recipeID
                              completeBlock:(TCRecipeCompleteBlock)completeBlock
{
    return [[TCRouxbeService sharedService] GET:[NSString stringWithFormat:TCRecipeXMLPath, recipeID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCRecipe *recipe = [[TCRecipe alloc] initWithXMLData:data];

        if (completeBlock) {
            completeBlock(recipe, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

#pragma mark - Initialize

- (id)initWithXMLData:(NSData *)data
{
    NSParameterAssert(data);

    self = [super init];
    if (self) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        _ID = [[rootXML attribute:@"id"] integerValue];
        _name = [rootXML attribute:@"name"];
        _steps = [self stepsWithXML:rootXML];
    }
    return self;
}

- (NSArray *)stepsWithXML:(RXMLElement *)rootXML
{
    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];

    [rootXML iterate:@"recipeSteps.recipeStep" usingBlock:^(RXMLElement *stepXML) {
        TCRecipeStep *step = [[TCRecipeStep alloc] initWithXML:stepXML
                                                    recipeName:self.name];
        [mutableSteps addObject:step];
    }];
    
    return mutableSteps;
}

@end
