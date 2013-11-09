//
//  NSString+FindSubstringAdditions.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "NSString+FindSubstringAdditions.h"

@implementation NSString (FindSubstringAdditions)

- (BOOL)containsString:(NSString *)aString options:(NSStringCompareOptions)options
{
    return NSNotFound != [self rangeOfString:aString options:options].location;
}

@end
