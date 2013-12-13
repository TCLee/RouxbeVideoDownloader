//
//  TCDownloadConfiguration.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/1/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

enum {
    /**
     * The default number of concurrent download operations to run.
     */
    TCDefaultMaxConcurrentDownloadOperationCount = 5
};

/**
 * The \c NSUserDefaults key for the maximum number of concurrent download 
 * operations. The value is an \c NSInteger.
 */
FOUNDATION_EXPORT NSString * const TCMaxConcurrentDownloadCountDefaultsKey;

/**
 * The \c NSUserDefaults key for the downloads directory URL. The value 
 * is an \c NSURL object.
 */
FOUNDATION_EXPORT NSString * const TCDownloadsDirectoryURLDefaultsKey;

/**
 * \c TCDownloadConfiguration class provides a set of properties to
 * configure an \c TCDownloadOperationManager instance.
 *
 * \c TCDownloadConfiguration persists its properties to a backing 
 * \c NSUserDefaults.
 */
@interface TCDownloadConfiguration : NSObject

/**
 * The URL to the directory that all downloads will be saved to.
 *
 * If no URL is specified, then it defaults to the user's Downloads directory.
 */
@property (readwrite, nonatomic, copy) NSURL *downloadsDirectoryURL;

/**
 * The maximum number of concurrent download operations that the
 * \c TCDownloadOperationManager operation queue can execute.
 *
 * If no value is specified, then it defaults to \c TCDefaultMaxConcurrentDownloadOperationCount.
 */
@property (readwrite, nonatomic, assign) NSUInteger maxConcurrentDownloadCount;

/**
 * Returns the shared \c TCDownloadConfiguration instance.
 */
+ (instancetype)sharedConfiguration;

@end
