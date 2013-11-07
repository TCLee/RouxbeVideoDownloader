//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCXMLLoader.h"
#import "TCVideoMP4URL.h"

/**
 * The URL to the Lesson's embedded video player XML.
 */
static NSString * const kEmbeddedLessonVideoXML = @"http://rouxbe.com/embedded_player/settings_section/%ld.xml";

@interface TCLessonStep ()

/**
 * The URL of this lesson step's video.
 *
 * We will cache the video URL after we have found it.
 */
@property (nonatomic, copy) NSURL *videoURL;

@end

@implementation TCLessonStep

- (id)initWithXMLElement:(RXMLElement *)element lesson:(TCLesson *)lesson
{
    self = [super init];

    if (self) {
        _lesson = lesson;
        _ID = [[element attribute:@"id"] integerValue];
        _position = [[element attribute:@"position"] integerValue];
        _name = [[element attribute:@"name"] copy];

        NSString *videoURLString = [element attribute:@"url"];
        _videoURL = videoURLString ? [[NSURL alloc] initWithString:videoURLString] : nil;
    }

    return self;
}

- (void)findVideoURLWithCompletion:(void (^)(NSURL *videoURL, NSError *error))completion
{
    // If we have the video URL in the cache, we will just return the video
    // URL immediately.
    if (_videoURL) {
        completion(_videoURL, nil);
        return;
    }

    // Get the video URL from the Lesson's embedded player XML.
    NSURL *xmlURL = [NSURL URLWithString:[NSString stringWithFormat:kEmbeddedLessonVideoXML, self.ID]];

    [TCXMLLoader loadXMLFromURL:xmlURL completion:^(RXMLElement *rootElement, NSError *error) {
        if (rootElement) {
            NSString *urlString = [[rootElement child:@"video"] attribute:@"url"];

            // By default, Rouxbe uses Flash videos. So, we have to convert the
            // Flash video URL to a MP4 video URL.
            NSURL *videoURL = [TCVideoMP4URL mp4VideoURLFromFlashVideoURL:[NSURL URLWithString:urlString]];
            completion(videoURL, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
