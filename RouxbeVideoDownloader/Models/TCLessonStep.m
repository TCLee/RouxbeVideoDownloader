//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCRouxbeService.h"
#import "TCMP4VideoURL.h"

/**
 * The string template representing the URL to a Lesson's video player XML.
 */
static NSString * const TCLessonVideoPlayerPath = @"embedded_player/settings_section/%ld.xml";

@interface TCLessonStep ()

@property (nonatomic, copy, readwrite) NSURL *videoURL;

/**
 * Set the MP4 video URL from the given string representing the
 * Flash video URL.
 *
 * @param URLString The string representing the video URL.
 */
- (void)setVideoURLWithString:(NSString *)URLString;

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
        [self setVideoURLWithString:[stepXML attribute:@"url"]];
    }
    return self;
}

#pragma mark - Fetch Video URL

- (AFHTTPRequestOperation *)videoURLRequestOperationWithCompletionHandler:(TCLessonStepVideoURLBlock)completionHandler
{
    return [[TCRouxbeService sharedService] HTTPRequestOperationWithPath:[NSString stringWithFormat:TCLessonVideoPlayerPath, self.ID] success:^(AFHTTPRequestOperation *operation, NSData *data) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];
        [self setVideoURLWithString:[[rootXML child:@"video"] attribute:@"url"]];

        if (completionHandler) {
            completionHandler(self.videoURL, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionHandler) {
            completionHandler(nil, [self stepErrorWithUnderlyingError:error]);
        }
    }];
}

- (void)setVideoURLWithString:(NSString *)URLString
{
    _videoURL = [TCMP4VideoURL MP4VideoURLWithString:URLString];
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
