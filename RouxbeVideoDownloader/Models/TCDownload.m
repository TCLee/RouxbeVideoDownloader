//
//  TCDownload.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownload.h"
#import "TCRouxbeAPIClient.h"

@interface TCDownload ()

@property (nonatomic, strong, readwrite) NSProgress *progress;

/**
 * Returns the user's default Downloads directory.
 *
 * @return The URL to the user's Downloads directory.
 */
- (NSURL *)defaultDownloadDirectoryURL;

/**
 * Creates the destination directory for the downloaded file.
 *
 * @return \c YES if directory was created; \c NO otherwise.
 */
- (BOOL)createDestinationDirectory;

@end

@implementation TCDownload

- (id)initWithSourceURL:(NSURL *)sourceURL
              groupName:(NSString *)groupName
               position:(NSUInteger)position
                   name:(NSString *)name
{
    self = [super init];

    if (self) {
        _downloadDirectoryURL = [self defaultDownloadDirectoryURL];
        _sourceURL = sourceURL;

        // Pad position with zero for numbers 1 to 9, so that Finder can
        // sort it properly. (i.e. 01, 02, 03 ... 09)
        // We add 1 to position so that the first position starts at 1, instead of 0.
        NSString *filename = [[NSString alloc] initWithFormat:@"%02lu - %@.mp4", position + 1, name];

        _name = [groupName stringByAppendingPathComponent:filename];
        _destinationURL = [_downloadDirectoryURL URLByAppendingPathComponent:_name];
    }

    return self;
}

- (NSURLSessionDownloadTask *)start
{
    // If we failed to create the destination directory for the downloaded file,
    // abort the download and report error back to caller.
    if (![self createDestinationDirectory]) {
        return nil;
    }

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.sourceURL];
    NSProgress *__autoreleasing outProgress = nil;

    NSURLSessionDownloadTask *downloadTask = [[TCRouxbeAPIClient sharedClient] downloadTaskWithRequest:request progress:&outProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return self.destinationURL;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (self.didComplete) {
            self.didComplete(filePath, error);
        }
    }];


    self.progress = outProgress;

    // 
    self.progress.kind = NSProgressKindFile;
    [self.progress setUserInfoObject:NSProgressFileOperationKindDownloading
                              forKey:NSProgressFileOperationKindKey];

    // Use Key-Value Observing (KVO) to observe progress and report back.
    [self.progress addObserver:self
                    forKeyPath:@"fractionCompleted"
                       options:NSKeyValueObservingOptionNew
                       context:NULL];

    // Tasks are suspended initially, so call resume to start download.
    [downloadTask resume];
    return downloadTask;
}

#pragma mark - File Operations

- (NSURL *)defaultDownloadDirectoryURL
{
    NSURL *downloadDirectoryURL = [[[NSFileManager defaultManager]
                                    URLsForDirectory:NSDownloadsDirectory
                                    inDomains:NSUserDomainMask] firstObject];

    NSAssert(downloadDirectoryURL, @"Could not locate the Downloads directory.");
    return downloadDirectoryURL;
}

- (BOOL)createDestinationDirectory
{
    NSURL *destinationDirectoryURL = [self.destinationURL URLByDeletingLastPathComponent];
    NSError *__autoreleasing error = nil;

    BOOL createdDirectory = [[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (!createdDirectory) {
        if (self.didComplete) {
            self.didComplete(nil, error);
        }
    }
    return createdDirectory;
}

#pragma mark - Key-Value Observing (KVO)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.progress && [keyPath isEqualToString:@"fractionCompleted"]) {
        // Switch back to main thread to make progress callback.
        // Otherwise, we'll end up updating the UI on another thread!
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.didChangeProgress) {
                self.didChangeProgress(self.progress);
            }
        });
    } else {
        // Only call the superclass if we don't handle the event.
        // Otherwise, it will throw an exception if the superclass (NSObject)
        // does not implement the method.
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)dealloc
{
    [self.progress removeObserver:self forKeyPath:@"fractionCompleted"];
}

@end
