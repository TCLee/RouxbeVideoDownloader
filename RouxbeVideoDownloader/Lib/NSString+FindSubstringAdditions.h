//
//  NSString+FindSubstringAdditions.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@interface NSString (FindSubstringAdditions)

/**
 * Returns a Boolean value that indicates whether a given string 
 * is found within the receiver. The given options will be used to 
 * determine the comparison method.
 *
 * @see NSString::rangeOfString:options
 *
 * @param aString The string to search for. This value must not be \c nil.
 * @param options A mask specifying search options.
 *
 * @return \c YES if \e aString is found; \c NO otherwise.
 */
- (BOOL)containsString:(NSString *)aString
               options:(NSStringCompareOptions)options;

@end
