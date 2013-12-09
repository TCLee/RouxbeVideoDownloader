//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the URL to a Lesson's video player XML.
 */
static NSString * const TCLessonVideoPlayerPath = @"embedded_player/settings_section/%ld.xml";

@interface TCLessonStep ()

@property (nonatomic, copy, readwrite) NSURL *videoURL;

@end

@implementation TCLessonStep

#pragma mark - Initialize

- (id)initWithXML:(RXMLElement *)stepXML lessonName:(NSString *)lessonName
{
    self = [super init];
    if (self) {
        _lessonName = [lessonName copy];
        
        _ID = [[stepXML attribute:@"id"] integerValue];
        _position = [[stepXML attribute:@"position"] integerValue];
        _name = [stepXML attribute:@"name"];
        _videoURL = [NSURL URLWithString:[stepXML attribute:@"url"]];
    }
    return self;
}

#pragma mark - Fetch Video URL

- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompleteBlock:(TCLessonStepVideoURLBlock)completeBlock
{
    TCRouxbeService *service = [TCRouxbeService sharedService];

    NSString *path = [NSString stringWithFormat:TCLessonVideoPlayerPath, self.ID];
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
            completeBlock(nil, [self stepErrorWithUnderlyingError:error]);
        }
    }];
}

/**
 * Returns a more detailed error object specific to the Lesson Step object.
 */
- (NSError *)stepErrorWithUnderlyingError:(NSError *)error
{
    NSMutableDictionary *mutableUserInfo = [[NSMutableDictionary alloc] initWithDictionary:error.userInfo];

    mutableUserInfo[NSLocalizedDescriptionKey] = [[NSString alloc] initWithFormat:
                                                  @"Lesson: %@\n"
                                                  "Step: ID = %lu, Position = %lu, Name = %@"
                                                  "Embedded Video Player XML: %@"
                                                  "Error: %@",
                                                  self.lessonName,
                                                  self.ID, self.position, self.name,
                                                  error.userInfo[NSURLErrorFailingURLStringErrorKey],
                                                  error.localizedDescription];

    return [[NSError alloc] initWithDomain:error.domain
                                      code:error.code
                                  userInfo:[mutableUserInfo copy]];
}

@end
