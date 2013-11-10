//
//  NSURL+RouxbeAdditions.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * An enumeration of the Rouxbe video categories.
 */
typedef NS_ENUM(NSInteger, TCRouxbeCategory) {
    /**
     * An unknown category, which indicates an error parsing the URL.
     */
    TCRouxbeCategoryUnknown = -1,
    /**
     * Rouxbe's video category for Lessons.
     */
    TCRouxbeCategoryLesson = 1,
    /**
     * Rouxbe's video category for Recipes.
     */
    TCRouxbeCategoryRecipe = 2,
    /**
     * Rouxbe's video category for Tips & Techniques.
     */
    TCRouxbeCategoryTip = 3
};

@interface NSURL (RouxbeAdditions)

/**
 * Returns whether the receiver is a valid Rouxbe URL to download videos from.
 *
 * @return \c YES if the receiver is a valid Rouxbe URL to download 
 * videos from; \c NO otherwise.
 */
- (BOOL)isValidRouxbeURL;

/**
 * Returns a \c TCRouxbeCategory constant describing the video's
 * category from the URL.
 *
 * @return \c TCRouxbeCategoryUnknown if the category cannot be determined; 
 *         otherwise it returns one of the other \c TCRouxbeCategory constants.
 */
- (TCRouxbeCategory)rouxbeCategory;

- (NSUInteger)rouxbeID;

/**
 * Returns the URL to the XML representation of the current URL.
 *
 * @return A new URL to the XML document.
 */
- (NSURL *)rouxbeXMLDocumentURL;

@end
