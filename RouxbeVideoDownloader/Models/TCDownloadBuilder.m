//
//  TCDownloadBuilder.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/14/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadBuilder.h"
#import "TCLessonDownloadBuilder.h"

#import "NSURL+RouxbeAdditions.h"

@implementation TCDownloadBuilder

+ (void)createDownloadsWithURL:(NSURL *)aURL
                       handler:(TCDownloadBuilderBlock)handler
{
    switch ([aURL rouxbeCategory]) {
        case TCRouxbeCategoryLesson:
            [TCLessonDownloadBuilder createDownloadsWithURL:aURL handler:handler];
            break;

        case TCRouxbeCategoryRecipe: {
            // Recipe Download Builder
            break;
        }

        case TCRouxbeCategoryTip: {
            // Tip Download Builder
            break;
        }

        default: {
            // Error - Unknown category or invalid rouxbe.com URL.
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorBadURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Example of a valid rouxbe.com URL:\nhttp://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock"}];
            handler(nil, error);
            break;
        }
    }

}

@end
