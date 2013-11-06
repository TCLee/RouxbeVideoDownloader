//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"
#import "TCLessonStep.h"

@implementation TCLesson

- (id)initWithXMLElement:(RXMLElement *)element
{
    self = [super init];
    if (self) {
        [self parsePropertiesFromXMLElement:element];
    }
    return self;
}

- (void)parsePropertiesFromXMLElement:(RXMLElement *)element
{
    _ID = [[element attribute:@"id"] integerValue];
    _name = [[element attribute:@"name"] copy];

    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];
    [element iterate:@"recipesteps.recipestep" usingBlock:^(RXMLElement *stepElement) {
        TCLessonStep *step = [[TCLessonStep alloc] initWithXMLElement:stepElement];
        [mutableSteps addObject:step];
    }];
    _steps = [mutableSteps copy];
}

@end
