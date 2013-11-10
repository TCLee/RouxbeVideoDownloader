//
//  NSURL+RouxbeAdditions.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "NSURL+RouxbeAdditions.h"

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
    if ([pathComponents[1] isEqualToString:@"cooking-school"] &&
        [pathComponents[2] isEqualToString:@"lessons"] &&
        pathComponents.count == 4) {
        // Find the Lesson ID. If found, then URL is valid.
        NSScanner *scanner = [[NSScanner alloc] initWithString:pathComponents[3]];
        return [scanner scanInteger:NULL];
    }

    // Tip URL = http://rouxbe.com/tips-techniques/98-what-are-pappadams-indian-flatbread
    // Path Components = ["/", "tips-techniques", "98-what-are-pappadams-indian-flatbread"]
    // Recipes URL = http://rouxbe.com/recipes/89-chicken-cashew
    // Path Components = ["/", "recipes", "89-chicken-cashew"]
    if (([pathComponents[1] isEqualToString:@"recipes"] ||
         [pathComponents[1] isEqualToString:@"tips-techniques"]) &&
        pathComponents.count == 3) {
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

    // Examples of the path components:
    // Lesson = ["/", "cooking-school", "lessons", "170-how-to-pan-fry"]
    // Recipe = ["/", "recipes", "89-chicken-cashew"]
    // Tip    = ["/", "tips-techniques", "98-what-are-pappadams-indian-flatbread"]

    if ([pathComponents[1] isEqualToString:@"recipes"]) {
        return TCRouxbeCategoryRecipe;
    } else if ([pathComponents[1] isEqualToString:@"tips-techniques"]) {
        return TCRouxbeCategoryTip;
    } else if ([pathComponents[2] isEqualToString:@"lessons"]) {
        return TCRouxbeCategoryLesson;
    }
    return TCRouxbeCategoryUnknown;
}

- (NSUInteger)rouxbeID
{
    if (![self isValidRouxbeURL]) {
        return NSNotFound;
    }

    //TODO: Not implemented yet.
    return 0;
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
