//
//  TCDownloadOperation.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/29/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadOperation.h"
#import "AFURLConnectionByteSpeedMeasure.h"

/**
 * The file extension to append to a temporary file used for 
 * resumable downloads.
 */
static NSString * const TCTemporaryFileExtension = @"tcdownload";

@interface TCDownloadOperation ()
/**
 * The \c AFURLConnectionByteSpeedMeasure object measures the download
 * speed and estimated time remaining.
 */
@property (readwrite, nonatomic, strong) AFURLConnectionByteSpeedMeasure *speedMeasure;

/**
 * The block object to execute when this download operation's progress or state has changed.
 */
@property (readwrite, nonatomic, copy) TCDownloadOperationDidChangeBlock downloadOperationDidChange;

@property (readwrite, nonatomic, strong) id downloadOperationDidStartObserver;
@property (readwrite, nonatomic, strong) id downloadOperationDidFinishObserver;

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
        _title = [title copy];
        _destinationURL = [destinationURL copy];

        // Create the directory (or directories) to contain the downloaded file.
        // If directory could not be created, then there is no point starting the download.
        BOOL directoryCreated = [self createDirectoryForDestinationURL:_destinationURL];
        if (!directoryCreated) { return nil; }

        [self initializeProgress];

        // Create and activate the download speed and estimated time remaining measurement.
        _speedMeasure = [[AFURLConnectionByteSpeedMeasure alloc] init];
        _speedMeasure.active = YES;

        [self configureProgressiveDownloadProgressBlock];
        [self registerForDownloadOperationNotifications];
    }
    return self;
}

/**
 * Create and initialize the \c NSProgress object used for tracking 
 * this download operation's progress.
 */
- (void)initializeProgress
{
    // Configure NSProgress to track the progress of file downloads.
    _progress = [[NSProgress alloc] initWithParent:nil
                                          userInfo:@{NSProgressFileOperationKindKey: NSProgressFileOperationKindDownloading}];
    _progress.kind = NSProgressKindFile;

    // Set the NSProgress object to be indeterminate, until we receive
    // some response data.
    _progress.completedUnitCount = -1;
    _progress.totalUnitCount = -1;
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
 * Configures the progressive download progress block to update our
 * download operation's progress.
 */
- (void)configureProgressiveDownloadProgressBlock
{
    __weak typeof(self) weakSelf = self;

    [self setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }

        // Re-calculate new average download speed.
        [strongSelf.speedMeasure updateSpeedWithDataChunkLength:bytesRead
                                                 receivedAtDate:[NSDate date]];

        // Update the download's progress (taking into account if a download was resumed).
        strongSelf.progress.completedUnitCount = totalBytesReadForFile;
        strongSelf.progress.totalUnitCount = totalBytesExpectedToReadForFile;

        // Update the download's current speed and estimated time to finish.
        [strongSelf.progress setUserInfoObject:@(strongSelf.speedMeasure.speed)
                                        forKey:NSProgressThroughputKey];
        [strongSelf.progress setUserInfoObject:@([strongSelf.speedMeasure remainingTimeOfTotalSize:totalBytesExpected numberOfCompletedBytes:totalBytesRead])
                                        forKey:NSProgressEstimatedTimeRemainingKey];

        // Callback to notify of progress updates.
        if (strongSelf.downloadOperationDidChange) {
            strongSelf.downloadOperationDidChange(strongSelf);
        }
    }];
}

/**
 * Register our observers to be notified when this download operation has
 * started or finished.
 */
- (void)registerForDownloadOperationNotifications
{
    __weak typeof(self) weakSelf = self;

    void(^notificationBlock)(NSNotification *) = ^(NSNotification *notification) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        // Callback to notify when download operation has started or finished.
        if (strongSelf.downloadOperationDidChange) {
            strongSelf.downloadOperationDidChange(strongSelf);
        }
    };

    self.downloadOperationDidStartObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingOperationDidStartNotification
                                                                                               object:self
                                                                                                queue:[NSOperationQueue mainQueue]
                                                                                           usingBlock:notificationBlock];
    self.downloadOperationDidFinishObserver = [[NSNotificationCenter defaultCenter] addObserverForName:AFNetworkingOperationDidFinishNotification
                                                                                                object:self
                                                                                                 queue:[NSOperationQueue mainQueue]
                                                                                            usingBlock:notificationBlock];
}

/**
 * Unregister our observers that we registered for this download operation's notifications.
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.downloadOperationDidStartObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.downloadOperationDidFinishObserver];
}

#pragma mark - AFDownloadRequestOperation: Temporary File Path

- (NSString *)tempPath
{
    // Replace AFDownloadRequestOperation default temporary file path with our own.
    return [self.targetPath stringByAppendingPathExtension:TCTemporaryFileExtension];
}

#pragma mark - Download Operation Did Change Callback

- (void)setDownloadOperationDidChangeBlock:(TCDownloadOperationDidChangeBlock)block
{
    self.downloadOperationDidChange = block;
}

#pragma mark - Download Operation Progress Description

- (NSString *)localizedProgressDescription
{
    // Empty string will be returned, if we cannot create the description.
    NSString *localizedProgressDescription = @"";

    if (self.isExecuting) {
        if (self.progress.isIndeterminate) {
            localizedProgressDescription = NSLocalizedString(@"Running...", @"Download operation is executing, but has no progress yet.");
        } else {
            localizedProgressDescription = [self.progress localizedAdditionalDescription];
        }
    } else if (self.isReady) {
        NSString *statusString = NSLocalizedString(@"Waiting...", @"Download operation is ready and waiting in the queue to be executed.");
        if (self.progress.isIndeterminate) {
            localizedProgressDescription = statusString;
        } else {
            localizedProgressDescription = [NSString stringWithFormat:@"%@ - %@",
                                            statusString, [self.progress localizedAdditionalDescription]];
        }
    } else if (self.isFinished) {
        // The download speed and estimated time remaining values are
        // no longer needed when download operation has finished.
        [self.progress setUserInfoObject:nil forKey:NSProgressEstimatedTimeRemainingKey];
        [self.progress setUserInfoObject:nil forKey:NSProgressThroughputKey];

        if (self.error) {
            if (NSURLErrorCancelled == self.error.code) {
                NSString *statusString = NSLocalizedString(@"Cancelled", @"Download Cancelled");
                if (self.progress.isIndeterminate) {
                    localizedProgressDescription = statusString;
                } else {
                    localizedProgressDescription = [NSString stringWithFormat:@"%@ - %@",
                                                    statusString,
                                                    [self.progress localizedAdditionalDescription]];
                }
            } else {
                localizedProgressDescription = [NSString stringWithFormat:@"%@ - %@",
                                                NSLocalizedString(@"Error", @"Download Error"),
                                                [self.error localizedDescription]];
            }
        } else {
            NSString *statusString = NSLocalizedString(@"Completed", @"Download Completed");
            if (self.progress.isIndeterminate) {
                localizedProgressDescription = statusString;
            } else {
                localizedProgressDescription = [NSString stringWithFormat:@"%@ - %@",
                                                statusString,
                                                [self.progress localizedAdditionalDescription]];
            }
        }
    }

    return localizedProgressDescription;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TCDownloadOperation *operation = [[[self class] allocWithZone:zone] initWithRequest:self.request
                                                                         destinationURL:self.destinationURL
                                                                                  title:self.title];

    // Make a copy of the download operation's block.
    operation.downloadOperationDidChange = self.downloadOperationDidChange;

    return operation;
}

@end
