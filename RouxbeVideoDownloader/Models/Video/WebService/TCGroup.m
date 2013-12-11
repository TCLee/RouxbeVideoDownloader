//
//  TCGroup.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/10/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCGroup.h"
#import "TCStep.h"

@interface TCGroup ()

@end

@implementation TCGroup

- (id)initWithXMLData:(NSData *)data stepsXMLPath:(NSString *)stepsXMLPath
{
    NSParameterAssert(data);
    NSParameterAssert(stepsXMLPath);

    self = [super init];
    if (self) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        _ID = [[rootXML attribute:@"id"] integerValue];
        _name = [rootXML attribute:@"name"];
        _steps = [self stepsWithXML:rootXML path:stepsXMLPath];
    }
    return self;
}

/**
 * Returns an array of \c TCStep objects from the XML.
 *
 * @param rootXML The root element of the XML document.
 * @param path    The path to the step elements in the XML.
 */
- (NSArray *)stepsWithXML:(RXMLElement *)rootXML path:(NSString *)path
{
    NSMutableArray *mutableSteps = [[NSMutableArray alloc] init];
    [rootXML iterate:path usingBlock:^(RXMLElement *stepXML) {
        TCStep *step = [[TCStep alloc] initWithXML:stepXML
                                         groupName:self.name];
        [mutableSteps addObject:step];
    }];
    return mutableSteps;
}

@end
