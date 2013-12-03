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
 * \c TCDownloadConfiguration class provides a set of properties to
 * configure an \c TCDownloadOperationManager instance.
 */
@interface TCDownloadConfiguration : NSObject <NSCopying>

/**
 * The URL to the directory that all downloads will be saved to.
 *
 * If no directory URL is specified, then it defaults to the user's 
 * Downloads directory.
 */
@property (nonatomic, copy) NSURL *downloadsDirectoryURL;

/**
 * The maximum number of concurrent download operations that the
 * \c TCDownloadOperationManager operation queue can execute.
 *
 * If no value is specified, then it defaults to 
 * \c TCDefaultMaxConcurrentDownloadOperationCount.
 */
@property (nonatomic, assign) NSUInteger maxConcurrentDownloadCount;

/**
 * Creates the default configuration for an \c TCDownloadOperationManager 
 * instance.
 *
 * You can customize the returned configuration as needed.
 */
+ (instancetype)defaultConfiguration;

@end
