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
            break;
        }
    }

}

@end
