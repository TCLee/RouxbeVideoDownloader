//
//  TCVideoFileTests.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@import XCTest;

#import "TCTestData.h"
#import "TCVideoFile.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

@interface TCVideoFileTests : XCTestCase

@end

@implementation TCVideoFileTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 * Test that the video file can be created properly from a lesson step object.
 */
- (void)testInitWithLessonStep
{
    RXMLElement *rootElement = [[RXMLElement alloc] initFromXMLData:[TCTestData XMLDataWithName:@"Lesson"]];
    TCLesson *lesson = [[TCLesson alloc] initWithXMLElement:rootElement];
    TCLessonStep *firstStep = [lesson.steps firstObject];

    TCVideoFile *videoFile = [[TCVideoFile alloc] initWithLessonStep:firstStep];
    videoFile.downloadDirectoryURL = [[NSURL alloc] initFileURLWithPath:@"/TestDownload/" isDirectory:YES];

    XCTAssertEqualObjects(videoFile.directoryName, lesson.name, @"The directory name should be the name of the lesson.");

    NSString *expectedFilename = [[NSString alloc] initWithFormat:@"01 - %@.mp4", firstStep.name];
    XCTAssertEqualObjects(videoFile.filename, expectedFilename, @"The video filename does not match the lesson step's name.");

    NSString *path = [[NSString alloc] initWithFormat:@"/TestDownload/%@/%@", lesson.name, expectedFilename];
    NSURL *expectedFileURL = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    XCTAssertEqualObjects([videoFile fileURL], expectedFileURL, @"The video file URL is referencing the wrong location.");
}

@end
