//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/16/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Lesson Step's video XML.
 */
static NSString * const TCLessonStepVideoXMLPath = @"embedded_player/settings_section/%ld.xml";

@interface TCLessonStep ()

@property (readwrite, nonatomic, copy) NSURL *videoURL;

@end

@implementation TCLessonStep

- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompleteBlock:(TCLessonStepVideoURLCompleteBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];

    NSString *path = [NSString stringWithFormat:TCLessonStepVideoXMLPath, self.ID];
    NSMutableURLRequest *request = [service.requestSerializer requestWithMethod:@"GET"
                                                                      URLString:[[NSURL URLWithString:path relativeToURL:service.baseURL] absoluteString]
                                                                     parameters:nil];

    return [service HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, NSData *data) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
        NSString *urlString = [[rootXML child:@"video"] attribute:@"url"];
        self.videoURL = urlString ? [NSURL URLWithString:urlString] : nil;

        if (completeBlock) {
            completeBlock(self.videoURL, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

@end
