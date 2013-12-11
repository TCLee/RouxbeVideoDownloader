//
//  TCTip.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/11/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCTip.h"
#import "TCRouxbeService.h"

/**
 * The string template representing the relative path to a Tip's video XML.
 */
static NSString * const TCTipXMLPath = @"embedded_player/settings_drilldown/%lu.xml";

@implementation TCTip

+ (AFHTTPRequestOperation *)getTipWithID:(NSUInteger)tipID
                           completeBlock:(TCTipCompleteBlock)completeBlock
{
    return [[TCRouxbeService sharedService] GET:[NSString stringWithFormat:TCTipXMLPath, tipID] parameters:nil success:^(AFHTTPRequestOperation *operation, NSData *data) {
        TCTip *tip = [[TCTip alloc] initWithXMLData:data];

        if (completeBlock) {
            completeBlock(tip, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completeBlock) {
            completeBlock(nil, error);
        }
    }];
}

- (id)initWithXMLData:(NSData *)data
{
    self = [super init];
    if (self) {
        RXMLElement *rootXML = [[RXMLElement alloc] initFromXMLData:data];

        _ID = [[rootXML attribute:@"id"] integerValue];
        _name = [rootXML attribute:@"title"];
        _videoURL = [NSURL URLWithString:[[rootXML child:@"video"] attribute:@"url"]];
    }
    return self;
}

@end
