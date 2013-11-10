//
//  NSURL+RouxbeAdditions.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "NSURL+RouxbeAdditions.h"

/**
 * Constant string describing the Lesson URL's path component.
 */
static NSString * const kLessonsPathComponent = @"lessons";
/**
 * Constant string describing the Recipe URL's path component.
 */
static NSString * const kRecipesPathComponent = @"recipes";
/**
 * Constant string describing the Tip & Technique URL's path component.
 */
static NSString * const kTipsPathComponent = @"tips-techniques";

@implementation NSURL (RouxbeAdditions)

- (BOOL)isValidRouxbeURL
{
    // If URL does not start with http://rouxbe.com, then it's
    // definitely not valid.
    if (![self.scheme isEqualToString:@"http"] ||
        ![self.host isEqualToString:@"rouxbe.com"]) {
        return NO;
    }

    NSArray *pathComponents = [self pathComponents];

    // First, make sure we have at minimum 3 path components. Otherwise,
    // we'll get array index out of bounds exception (NSRangeException) when
    // performing subsequent tests.
    if (pathComponents.count < 3) {
        return NO;
    }

    // Lesson URL = http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry
    // Path Components = ["/", "cooking-school", "lessons", "170-how-to-pan-fry"]
    // Lesson URL = http://rouxbe.com/cooking-school/lessons/170-how-to-pan-fry/details
    // Path Components = ["/", "cooking-school", "lessons", "170-how-to-pan-fry", "details"]
    if ([pathComponents[1] isEqualToString:@"cooking-school"] &&
        [pathComponents[2] isEqualToString:kLessonsPathComponent]) {
        if (pathComponents.count >= 4) {
            // Find the Lesson ID. If found, then URL is valid.
            NSScanner *scanner = [[NSScanner alloc] initWithString:pathComponents[3]];
            return [scanner scanInteger:NULL];
        }
    }

    // Tip URL = http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread
    // Path Components = ["/", "tips-techniques", "98-what-are-pappadams-indian-flatbread"]
    // Recipes URL = http://rouxbe.com/recipes/89-chicken-cashew
    // Path Components = ["/", "recipes", "89-chicken-cashew"]
    // Recipes URL = http://rouxbe.com/recipes/89-chicken-cashew/text
    // Path Components = ["/", "recipes", "89-chicken-cashew", "text"]
    if ([pathComponents[1] isEqualToString:kRecipesPathComponent] ||
        [pathComponents[1] isEqualToString:kTipsPathComponent]) {
        // Find the Tip or Recipe ID. If found, then URL is valid.
        NSScanner *scanner = [[NSScanner alloc] initWithString:pathComponents[2]];
        return [scanner scanInteger:NULL];
    }

    // By default, we assume it's an invalid URL until proven otherwise.
    return NO;
}

- (TCRouxbeCategory)rouxbeCategory
{
    // Cannot extract a category from an invalid Rouxbe URL.
    if (![self isValidRouxbeURL]) {
        return TCRouxbeCategoryUnknown;
    }

    NSArray *pathComponents = [self pathComponents];

    if ([pathComponents[1] isEqualToString:kRecipesPathComponent]) {
        return TCRouxbeCategoryRecipe;
    } else if ([pathComponents[1] isEqualToString:kTipsPathComponent]) {
        return TCRouxbeCategoryTip;
    } else if ([pathComponents[2] isEqualToString:kLessonsPathComponent]) {
        return TCRouxbeCategoryLesson;
    }
    return TCRouxbeCategoryUnknown;
}

- (NSUInteger)rouxbeID
{
    // Cannot extract ID if URL is invalid in the first place.
    if (![self isValidRouxbeURL]) {
        return NSNotFound;
    }

    // Find out the index of the path component that contains the Rouxbe ID.
    NSUInteger contentPathIndex =
        [self rouxbeCategory] == TCRouxbeCategoryLesson ? 3 : 2;

    // Extract the ID from the path component at that index.
    NSInteger contentID = 0;
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [self pathComponents][contentPathIndex]];
    return [scanner scanInteger:&contentID] ? contentID : NSNotFound;
}

- (NSURL *)rouxbeXMLDocumentURL
{
    if (![self isValidRouxbeURL]) {
        return nil;
    }

    // To get the XML representation of a URL resource, we just add
    // the extension 'xml'.
    return [self URLByAppendingPathExtension:@"xml"];
}

@end
