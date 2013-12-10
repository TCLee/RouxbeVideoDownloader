//
//  TCRecipeStep.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/9/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCRecipeStep.h"

@implementation TCRecipeStep

- (id)initWithXML:(RXMLElement *)stepXML recipeName:(NSString *)recipeName
{
    self = [super init];
    if (self) {
        _recipeName = [recipeName copy];

        _ID = [[stepXML attribute:@"id"] integerValue];
        _position = [[stepXML attribute:@"position"] integerValue];
        _name = [stepXML attribute:@"name"];
        _videoURL = [NSURL URLWithString:[stepXML attribute:@"url"]];
        _imageURL = [NSURL URLWithString:[stepXML attribute:@"posterframe_url"]];
    }
    return self;
}

@end
