//
//  TCDownloadOperation.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/29/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadOperation.h"
#import "AFURLConnectionOperation+AFURLConnectionByteSpeedMeasure.h"

/**
 * The file extension to append to a temporary file used for
 * resumable downloads.
 */
static NSString * const TCTemporaryFileExtension = @"tcdownload";

@interface TCDownloadOperation ()

/**
 * The object that acts as an observer to this download operation's
 * start notification.
 */
@property (readwrite, nonatomic, strong) id downloadOperationDidStartObserver;

@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didStartCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didUpdateProgressCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didFailCallback;
@property (readwrite, nonatomic, copy) TCDownloadOperationBlock didFinishCallback;

@end

@implementation TCDownloadOperation

#pragma mark - Initialize

- (instancetype)initWithRequest:(NSURLRequest *)theRequest
                 destinationURL:(NSURL *)destinationURL
                          title:(NSString *)title
{
    NSParameterAssert(theRequest);
    NSParameterAssert(destinationURL);

    self = [super initWithRequest:theRequest
                       targetPath:[destinationURL path]
                     shouldResume:YES];
    if (self) {
        // Create the directory (or directories) to contain the downloaded file.
        // If directory could not be created, then there is no point starting the download.
        BOOL directoryCreated = [self createDirectoryForDestinationURL:destinationURL];
        if (!directoryCreated) { return nil; }

        _title = [title copy];
        _destinationURL = [destinationURL copy];

        [self initializeProgressProperties];

        // Combine the various notifications and callbacks into a unified
        // simpler callback for client classes.
        [self registerForDownloadStartNotification];
        [self registerForDownloadProgressCallback];
        [self registerForDownloadCompletionCallback];
    }
    return self;
}

/**
 * Create and initialize the properties used for tracking
 * this download operation's progress.
 *
 * - \c NSProgress object for keeping track of the downloaded bytes
 * - \c AFURLConnectionByteSpeedMeasure object for measuring download speed
 *   and estimated time remaining.
 */
- (void)initializeProgressProperties
{
    // Configure NSProgress to track the progress of file downloads.
    _progress = [[NSProgress alloc] initWithParent:nil
                                          userInfo:@{NSProgressFileOperationKindKey: NSProgressFileOperationKindDownloading}];
    _progress.kind = NSProgressKindFile;

    // Show the file icon with download progress in Finder.
    NSImage *fileIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"mp4"];
    [_progress setUserInfoObject:fileIcon forKey:NSProgressFileIconKey];

    // Set the NSProgress object to be indeterminate, until we receive
    // some response data.
    _progress.completedUnitCount = -1;
    _progress.totalUnitCount = -1;

    // Create and activate the download speed and estimated time remaining
    // measurement.
    self.downloadSpeedMeasure.active = YES;
}

/**
 * Creates the directory (or directories) to contain the downloaded file.
 *
 * @param destinationURL The URL where the downloaded file should be saved to.
 *
 * @return \c YES if directory (or directories) was created; \c NO otherwise.
 *         If the directory already exists, it will also return \c YES.
 */
- (BOOL)createDirectoryForDestinationURL:(NSURL *)destinationURL
{
    NSURL *destinationDirectoryURL = [destinationURL URLByDeletingLastPathComponent];

    NSError *__autoreleasing error = nil;
    BOOL directoryCreated = [[NSFileManager defaultManager] createDirectoryAtURL:destinationDirectoryURL
                                                     withIntermediateDirectories:YES
                                                                      attributes:nil
                                                                           error:&error];
    if (!directoryCreated) {
        NSLog(@"Failed to create destination directory for download.\nFailed URL - %@\nError - %@",
              [error.userInfo[NSURLErrorFailingURLErrorKey] path], [error localizedDescription]);
    }

    return directoryCreated;
}

/**
 * Register an observer to be notified when the download operation has started.
 */
- (void)registerForDownloadStartNotification
{
    self.downloadOperationDidStartObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingOperationDidStartNotification object:self queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        TCDownloadOperation *downloadOperation = notification.object;

        if (downloadOperation.didStartCallback) {
            downloadOperation.didStartCallback(downloadOperation);
        }
    }];
}

/**
 * Register a block object to be called when the download operation has
 * made some progress.
 */
- (void)registerForDownloadProgressCallback
{
    __weak typeof(self) weakSelf = self;

    [self setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        // Update the download's progress (taking into account if a download was resumed).
        strongSelf.progress.completedUnitCount = totalBytesReadForFile;
        strongSelf.progress.totalUnitCount = totalBytesExpectedToReadForFile;

        // Update the download's current speed and estimated time to finish.
        [strongSelf.progress setUserInfoObject:@(strongSelf.downloadSpeedMeasure.speed)
                                        forKey:NSProgressThroughputKey];
        [strongSelf.progress setUserInfoObject:@([strongSelf.downloadSpeedMeasure remainingTimeOfTotalSize:totalBytesExpected numberOfCompletedBytes:totalBytesRead])
                                        forKey:NSProgressEstimatedTimeRemainingKey];

        // Callback to notify of progress updates.
        if (strongSelf.didUpdateProgressCallback) {
            strongSelf.didUpdateProgressCallback(strongSelf);
        }
    }];
}

/**
 * Register a block object to be called when the download operation has
 * completed.
 */
- (void)registerForDownloadCompletionCallback
{
    __weak typeof(self) weakSelf = self;

    [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf operationDidCompleteWithSuccess:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf operationDidCompleteWithSuccess:NO];
    }];
}

/**
 * This method is only called when this download operation has finished.
 *
 * @param success Pass in \c YES to indicate that operation completed 
 *                successfully; \c NO to indicate failure.
 */
- (void)operationDidCompleteWithSuccess:(BOOL)success
{
    // The download speed and estimated time remaining values are
    // no longer needed when download operation has finished.
    [self.progress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
    [self.progress setUserInfoObject:nil forKey:NSProgressThroughputKey];

    if (success) {
        if (self.didFinishCallback) {
            self.didFinishCallback(self);
        }
    } else {
        if (self.didFailCallback) {
            self.didFailCallback(self);
        }
    }
}

/**
 * Unregister our observers that we registered for this download operation's notifications.
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.downloadOperationDidStartObserver];
}

#pragma mark - AFDownloadRequestOperation Override

- (NSString *)tempPath
{
    // Replace AFDownloadRequestOperation default temporary file path with our own.
    return [self.targetPath stringByAppendingPathExtension:TCTemporaryFileExtension];
}

#pragma mark - Download Operation Callbacks

- (void)setDidStartBlock:(TCDownloadOperationBlock)block
{
    self.didStartCallback = block;
}

- (void)setDidUpdateProgressBlock:(TCDownloadOperationBlock)block
{
    self.didUpdateProgressCallback = block;
}

- (void)setDidFinishBlock:(TCDownloadOperationBlock)block
{
    self.didFinishCallback = block;
}

- (void)setDidFailBlock:(TCDownloadOperationBlock)block
{
    self.didFailCallback = block;
}

#pragma mark - Progress Description String

- (NSString *)localizedProgressDescription
{
    if (self.isExecuting) {
        return [self descriptionWithTitle:NSLocalizedString(@"Starting...", @"Download Operation is Executing")
                                 progress:self.progress
                                exclusive:YES];
    } else if (self.isReady) {
        return [self descriptionWithTitle:NSLocalizedString(@"Waiting...", @"Download Operation is Ready but not Executing")
                                 progress:self.progress
                                exclusive:NO];
    } else if (self.isFinished) {
        if (self.error) {
            if (NSURLErrorCancelled == self.error.code) {
                return [self descriptionWithTitle:NSLocalizedString(@"Cancelled", @"Download Operation Finished as Cancelled.")
                                         progress:self.progress
                                        exclusive:NO];
            } else {
                return [self descriptionWithTitle:NSLocalizedString(@"Error", @"Download Operation Finished with Error")
                                            error:self.error];
            }
        } else {
            return [self descriptionWithTitle:NSLocalizedString(@"Completed", @"Download Operation Finished Successfully")
                                     progress:self.progress
                                    exclusive:NO];
        }
    }

    // Return empty string if we fail to generate the progress description.
    return @"";
}

/**
 * Returns a string describing the download operation's error.
 *
 * @see TCDownloadOperation::localizedProgressDescription
 *
 * @param title The title string to prepend before the error description.
 * @param error The \c NSError object that contains the error description.
 */
- (NSString *)descriptionWithTitle:(NSString *)title
                             error:(NSError *)error
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:title];

    if (error) {
        NSString *errorDescription = error.localizedDescription;

        if (errorDescription.length > 0) {
            [description appendFormat:@" - %@", error.localizedDescription];
        }
    }

    return description;
}

/**
 * Returns a string describing the download operation's progress.
 *
 * @see TCDownloadOperation::localizedProgressDescription
 *
 * @param title     The title string to prepend before the progress description.
 * @param progress  The \c NSProgress object representing the download 
 *                  operation's progress. The NSProgress \c localizedAdditionalDescription 
                    string will only be used, if the NSProgress \c isIndeterminate returns \c NO.
 * @param exclusive Set to \c YES to display either title \b or progress description.
 *                  Set to \c NO to display both title \b and progress description.
 */
- (NSString *)descriptionWithTitle:(NSString *)title
                          progress:(NSProgress *)progress
                         exclusive:(BOOL)exclusive
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:title];

    if (progress && !progress.isIndeterminate) {
        NSString *progressString = [progress localizedAdditionalDescription];

        if (progressString.length > 0) {
            if (exclusive) {
                [description setString:progressString];
            } else {
                [description appendFormat:@" - %@", progressString];
            }
        }
    }

    return description;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TCDownloadOperation *operation = [[[self class] allocWithZone:zone] initWithRequest:self.request
                                                                         destinationURL:self.destinationURL
                                                                                  title:self.title];

    // Make a copy of all the download operation's blocks.
    operation.didStartCallback = self.didStartCallback;
    operation.didUpdateProgressCallback = self.didUpdateProgressCallback;
    operation.didFinishCallback = self.didFinishCallback;
    operation.didFailCallback = self.didFailCallback;
    
    return operation;
}

@end
