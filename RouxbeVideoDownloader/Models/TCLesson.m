//
//  TCLesson.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/6/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCLesson.h"
#import "TCLessonStep.h"
#import "TCXMLService.h"

/**
 * The string template representing the URL to a Lesson's XML.
 */
static NSString * const kLessonURLString = @"http://rouxbe.com/cooking-school/lessons/%lu.xml";

@implementation TCLesson

+ (void)lessonWithID:(NSUInteger)lessonID
   completionHandler:(TCLessonBlock)completionHandler
{
    NSURL *lessonURL = [NSURL URLWithString:
                        [NSString stringWithFormat:kLessonURLString, lessonID]];
    [TCXMLService requestXMLDataWithURL:lessonURL completion:^(NSData *data, NSError *error) {
        completionHandler([[TCLesson alloc] initWithXMLData:data], error);
    }];
}

- (id)initWithXMLData:(NSData *)data
{
    self = [super init];
    if (self) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        _ID = [[rootXML attribute:@"id"] integerValue];
        _name = [rootXML attribute:@"name"];
        _steps = [self stepsWithXML:rootXML];
    }
    return self;
}

- (NSArray *)stepsWithXML:(RXMLElement *)rootXML
{
    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];

    // Create a TCLessonStep object from each step XML element.
    [rootXML iterate:@"recipesteps.recipestep" usingBlock:^(RXMLElement *stepXML) {
        TCLessonStep *step = [[TCLessonStep alloc] initWithXML:stepXML
                                                    lessonName:self.name];
        [mutableSteps addObject:step];
    }];

    return [mutableSteps copy];
}

@end
