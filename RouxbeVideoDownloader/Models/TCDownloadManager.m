//
//  TCDownloadManager.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/5/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadManager.h"
#import "TCDownload.h"

#import "AFURLConnectionByteSpeedMeasure.h"

#import "NSURL+RouxbeAdditions.h"
#import "TCLesson.h"
#import "TCLessonStep.h"

/**
 * The URL to the Tips & Technique embedded video player XML.
 */
static NSString * const kEmbeddedTipVideoXML = @"http://rouxbe.com/embedded_player/settings_drilldown/%ld.xml";

@interface TCDownloadManager ()

/**
 * The session manager that manages the session object used for coordinating 
 * all the download tasks.
 */
@property (nonatomic, strong, readonly) AFURLSessionManager *sessionManager;

/**
 * The mutable version of our download queue for use internally only.
 */
@property (nonatomic, copy, readonly) NSMutableArray *mutableDownloadQueue;

@end

@implementation TCDownloadManager

@synthesize sessionManager = _sessionManager;
@synthesize mutableDownloadQueue = _mutableDownloadQueue;

#pragma mark - Session Manager

- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

        __weak typeof(self)weakSelf = self;

        // This block will be called when any of the running download task has
        // downloaded some bytes of data.
        [_sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            NSDate *now = [NSDate date];

            // Get the download associated with the task.
            TCDownload *download = [weakSelf downloadForTask:downloadTask];

            dispatch_async(dispatch_get_main_queue(), ^{
                // Re-calculate new average download speed.
                [download.speedMeasure updateSpeedWithDataChunkLength:bytesWritten
                                                       receivedAtDate:now];

                // Update the download's progress.
                download.progress.completedUnitCount = totalBytesWritten;
                download.progress.totalUnitCount = totalBytesExpectedToWrite;

                // Update the download's current speed and estimated time to finish.
                [download.progress setUserInfoObject:@(download.speedMeasure.speed)
                                              forKey:NSProgressThroughputKey];
                [download.progress setUserInfoObject:@([download.speedMeasure remainingTimeOfTotalSize:totalBytesExpectedToWrite numberOfCompletedBytes:totalBytesWritten])
                                              forKey:NSProgressEstimatedTimeRemainingKey];
                
                if (weakSelf.downloadDidChangeProgress) {
                    weakSelf.downloadDidChangeProgress(download);
                }
            });
        }];
    }
    return _sessionManager;
}

- (TCDownload *)downloadForTask:(NSURLSessionDownloadTask *)downloadTask
{
    return nil;
//    return self.downloads[@(downloadTask.taskIdentifier)];
}

#pragma mark - Download Queue

- (NSMutableArray *)mutableDownloadQueue
{
    if (!_mutableDownloadQueue) {
        _mutableDownloadQueue = [[NSMutableArray alloc] init];
    }
    return _mutableDownloadQueue;
}

- (NSArray *)downloadQueue
{
    // Return the immutable copy of our download queue.
    return [self.mutableDownloadQueue copy];
}

- (void)addDownloadsWithURL:(NSURL *)theURL
{
    NSParameterAssert(theURL);

    switch ([theURL rouxbeCategory]) {
        case TCRouxbeCategoryLesson:
            [self addLessonDownloadsWithURL:theURL];
            break;

        case TCRouxbeCategoryRecipe:
            break;

        case TCRouxbeCategoryTip:
            break;

        default: {
            // Error - Unknown category or invalid rouxbe.com URL.
            NSError *error = [[NSError alloc] initWithDomain:NSURLErrorDomain
                                                        code:NSURLErrorBadURL
                                                    userInfo:@{NSLocalizedDescriptionKey: @"The URL is not a valid rouxbe.com URL.",
                                                               NSLocalizedRecoverySuggestionErrorKey: @"Example of a valid rouxbe.com URL:\nhttp://rouxbe.com/cooking-school/lessons/198-how-to-make-veal-beef-stock"}];
            self.didAddDownload(nil, error);
            break;
        }
    }
}

#pragma mark - Lesson Downloads

- (void)addLessonDownloadsWithURL:(NSURL *)theURL
{
    [TCLesson lessonWithID:[theURL rouxbeID] completionHandler:^(TCLesson *lesson, NSError *error) {
        if (lesson) {
            for (TCLessonStep *step in lesson.steps) {
                [self addDownloadWithLessonStep:step];
            }
        } else {
            // Error - Failed to fetch Lesson.
            self.didAddDownload(nil, error);
        }
    }];
}

- (void)addDownloadWithLessonStep:(TCLessonStep *)lessonStep
{
    [lessonStep videoURLWithCompletionHandler:^(NSURL *videoURL, NSError *error) {
        if (videoURL) {
//            NSURLRequest *request = [NSURLRequest requestWithURL:videoURL];
//            NSURLSessionDownloadTask *downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:NULL destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
//                // TODO: Return the destination URL.
//                return nil;
//            } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//                self.downloadDidComplete([self downloadForTask:downloadTask], error);
//            }];
//
//            TCDownload *download = [[TCDownload alloc] initWithTask:downloadTask];
//            [download.downloadTask resume];
//            [self.mutableDownloadQueue addObject:download];
//
//            if (self.didAddDownload) {
//                self.didAddDownload(download, nil);
//            }
        } else {
            // Error - Failed to retrieve Lesson Step's video URL.
            if (self.didAddDownload) {
                self.didAddDownload(nil, error);
            }
        }
    }];
}

//- (void)addDownloadsWithURL:(NSURL *)theURL
//{
//    NSParameterAssert(theURL);
//
//    // Download Builder will create the appropriate downloads from the given URL.
//    // The handler block will be called multiple times, once for each download created.
//    [TCDownloadBuilder createDownloadsWithURL:theURL handler:^(TCDownload *download, NSError *error) {
//        if (download) {
//            __weak typeof(self)weakSelf = self;
//            __weak typeof(download)weakDownload = download;
//
//            // Callback when this download has completed or failed.
//            download.didComplete = ^(NSURL *fileURL, NSError *error) {
//                if (weakSelf.downloadDidComplete) {
//                    weakSelf.downloadDidComplete(weakDownload, error);
//                }
//
//                // Remove finished download from queue.
//                [weakSelf.mutableDownloadQueue removeObject:weakDownload];
//            };
//
//            // Callback when this download has updated progress.
//            download.didChangeProgress = ^(NSProgress *progress) {
//                if (weakSelf.downloadDidChangeProgress) {
//                    weakSelf.downloadDidChangeProgress(weakDownload);
//                }
//            };
//
//            // Add new download to queue and start it.
//            [self.mutableDownloadQueue addObject:download];
//            [download.downloadTask resume];
//
//            if (self.didAddDownload) {
//                self.didAddDownload(download, nil);
//            }
//        } else {
//            // Error - Failed to create and add download.
//            if (self.didAddDownload) {
//                self.didAddDownload(nil, error);
//            }
//        }
//    }];
//}

@end
