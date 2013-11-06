//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"

@implementation TCLesson

- (id)initWithXMLData:(NSData *)xmlData
{
    self = [super init];
    if (self) {
        [self parsePropertiesFromXML:xmlData];
    }
    return self;
}

- (void)parsePropertiesFromXML:(NSData *)xmlData
{
    RXMLElement *lessonElement = [RXMLElement elementFromXMLData:xmlData];
    _ID = [[lessonElement attribute:@"id"] integerValue];
    _name = [[lessonElement attribute:@"name"] copy];

    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];
    [lessonElement iterate:@"recipesteps.recipestep" usingBlock:^(RXMLElement *stepElement) {
        [mutableSteps addObject:stepElement];
    }];
    _steps = [mutableSteps copy];
}

@end
