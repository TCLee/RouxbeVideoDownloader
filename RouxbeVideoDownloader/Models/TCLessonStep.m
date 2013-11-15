//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCXMLService.h"
#import "TCMP4VideoURL.h"

/**
 * The string template representing the URL to a Lesson's video player XML.
 */
static NSString * const kLessonVideoPlayerURLString = @"http://rouxbe.com/embedded_player/settings_section/%ld.xml";

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

- (void)videoURLWithCompletionHandler:(TCLessonStepVideoURLBlock)completionHandler
{
    // If we already have cached the video URL, we can return it immediately.
    if (self.videoURL) {
        completionHandler(self.videoURL, nil);
        return;
    }

    // Otherwise, we will have to extract the video URL from the video player.
    NSURL *videoPlayerURL = [NSURL URLWithString:
                             [NSString stringWithFormat:kLessonVideoPlayerURLString, self.ID]];

    [TCXMLService requestXMLDataWithURL:videoPlayerURL completion:^(NSData *data, NSError *error) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        [self setVideoURLWithString:
         [[rootXML child:@"video"] attribute:@"url"]];

        completionHandler(self.videoURL, error);
    }];
}

- (void)setVideoURLWithString:(NSString *)URLString
{
    _videoURL = [TCMP4VideoURL MP4VideoURLWithString:URLString];
}

@end
