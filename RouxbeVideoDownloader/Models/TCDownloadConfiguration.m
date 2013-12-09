//
//  TCDownloadConfiguration.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/1/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadConfiguration.h"

/**
 * Return the user's Downloads directory.
 *
 * @note Raises an \c NSInternalInconsistencyException, if user's Downloads
 *       directory could not be located.
 */
FOUNDATION_STATIC_INLINE NSURL *TCUserDownloadsDirectoryURL()
{
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory
                                                                  inDomains:NSUserDomainMask] firstObject];
    if (!directoryURL) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"%s - User's Downloads directory should exist.", __PRETTY_FUNCTION__];
    }

    return directoryURL;
}

@implementation TCDownloadConfiguration

#pragma mark - Initialize

+ (instancetype)defaultConfiguration
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _downloadsDirectoryURL = TCUserDownloadsDirectoryURL();
        _maxConcurrentDownloadCount = TCDefaultMaxConcurrentDownloadOperationCount;
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    TCDownloadConfiguration *configuration = [[[self class] allocWithZone:zone] init];

    configuration.downloadsDirectoryURL = [self.downloadsDirectoryURL copyWithZone:zone];
    configuration.maxConcurrentDownloadCount = self.maxConcurrentDownloadCount;

    return configuration;
}

@end
