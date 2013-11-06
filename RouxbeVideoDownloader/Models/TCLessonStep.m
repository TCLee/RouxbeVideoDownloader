//
//  TCLessonStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLessonStep.h"
#import "TCXMLLoader.h"

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

- (id)initWithXMLElement:(RXMLElement *)element
{
    self = [super init];

    if (self) {
        _ID = [[element attribute:@"id"] integerValue];
        _position = [[element attribute:@"position"] integerValue];
        _name = [[element attribute:@"name"] copy];

        NSString *urlString = [element attribute:@"url"];
        _videoURL = urlString ? [[NSURL alloc] initWithString:urlString] : nil;
    }

    return self;
}

- (void)findVideoURLWithCompletion:(void (^)(NSURL *videoURL, NSError *error))completion
{
    // We've already retrieved the video URL previously.
    if (_videoURL) { return; }

    // Get the video URL from the embedded player's XML.
    NSString *xmlURLString = [[NSString alloc] initWithFormat:kEmbeddedLessonVideoXML, self.ID];
    NSURL *xmlURL = [[NSURL alloc] initWithString:xmlURLString];

    [TCXMLLoader loadXMLFromURL:xmlURL completion:^(RXMLElement *rootElement, NSError *error) {
        if (rootElement) {
            NSString *videoURLString = [[rootElement child:@"video"] attribute:@"url"];
            NSURL *videoURL = [[NSURL alloc] initWithString:videoURLString];
            completion(videoURL, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
