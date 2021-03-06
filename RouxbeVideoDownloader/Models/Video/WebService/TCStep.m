//
//  TCStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCStep.h"

@interface TCStep ()

@property (readwrite, nonatomic, copy) NSURL *videoURL;

@end

@implementation TCStep

- (id)initWithXML:(RXMLElement *)stepXML groupName:(NSString *)groupName
{
    self = [super init];
    if (self) {
        _groupName = [groupName copy];

        _ID = [[stepXML attribute:@"id"] integerValue];
        _position = [[stepXML attribute:@"position"] integerValue];
        _name = [stepXML attribute:@"name"];
        _videoURL = [NSURL URLWithString:[stepXML attribute:@"url"]];
    }
    return self;
}

@end
