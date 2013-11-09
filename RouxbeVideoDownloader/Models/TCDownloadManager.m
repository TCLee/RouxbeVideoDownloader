//
//  TCDownloadManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadManager.h"

/**
 * The URL to the Lesson embedded video player XML.
 */
static NSString * const kEmbeddedLessonVideoXML = @"http://rouxbe.com/embedded_player/settings_section/%ld.xml";

/**
 * The URL to the Tips & Technique embedded video player XML.
 */
static NSString * const kEmbeddedTipVideoXML = @"http://rouxbe.com/embedded_player/settings_drilldown/%ld.xml";

/**
 * URL to get the MP4 version of the video rather than the default Flash video.
 * Downloading the video in MP4 makes it compatible with iOS devices.
 */
static NSString * const kMP4VideoURLString = @"http://media.rouxbe.com/itouch/mp4/%@.mp4";

@interface TCDownloadManager ()

@end

@implementation TCDownloadManager

- (id)initWithDelegate:(id<TCDownloadManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)addDownloadsWithURL:(NSURL *)url
{

}

- (void)addDownloadsWithURL:(NSURL *)theURL completion:(void (^)(NSArray *downloads, NSError *error))completion
{
    NSArray *pathComponents = [theURL pathComponents];

    // Second last component of the path represents the category.
    NSString *category = pathComponents[pathComponents.count - 2];

    if ([category isEqualToString:@"lessons"]) {

    } else if ([category isEqualToString:@"recipes"]) {

    } else if ([category isEqualToString:@"tips-techniques"]) {
        // Last component of the path represents the content URL itself.
        NSString *contentURL = pathComponents.lastObject;

        // Extract the content's ID from the content URL.
        NSScanner *scanner = [[NSScanner alloc] initWithString:contentURL];
        NSInteger contentID = -1;
        [scanner scanInteger:&contentID];
        NSLog(@"Tip ID: %ld", contentID);
    } else {
        // Error - Invalid URL
    }
}

- (void)getXMLForURL:(NSURL *)URL completion:(void (^)(NSData *xmlData, NSError *error))completion
{
    NSURL *xmlURL = [URL URLByAppendingPathExtension:@"xml"];

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:[xmlURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
