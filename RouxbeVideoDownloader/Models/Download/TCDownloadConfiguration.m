//
//  TCDownloadConfiguration.m
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 12/1/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

#import "TCDownloadConfiguration.h"

NSString * const TCMaxConcurrentDownloadCountDefaultsKey = @"TCMaxConcurrentDownloadCount";
NSString * const TCDownloadsDirectoryURLDefaultsKey = @"TCDownloadsDirectoryURL";

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

@interface TCDownloadConfiguration ()

/**
 * Returns the \c NSUserDefaults instance that is used by this receiver.
 */
@property (readwrite, nonatomic, strong) NSUserDefaults *defaults;

@end

@implementation TCDownloadConfiguration

#pragma mark - Shared Configuration

+ (instancetype)sharedConfiguration
{
    static TCDownloadConfiguration *_sharedConfiguration = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedConfiguration = [[TCDownloadConfiguration alloc] init];
    });

    return _sharedConfiguration;
}

#pragma mark - Initialize

- (id)init
{
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];

        [self registerDefaults];
    }
    return self;
}

/**
 * Register default values for preferences that may not have been set yet.
 * (i.e. first time launching this app)
 */
- (void)registerDefaults
{
    // See documentation for NSUserDefaults::setURL:forKey: on how to save
    // a path-based file: scheme URL.
    NSString *downloadsDirectoryPath = [[TCUserDownloadsDirectoryURL() path] stringByAbbreviatingWithTildeInPath];

    NSDictionary *defaultsDictionary = @{TCMaxConcurrentDownloadCountDefaultsKey: @(TCDefaultMaxConcurrentDownloadOperationCount),
                                         TCDownloadsDirectoryURLDefaultsKey: downloadsDirectoryPath};
    [self.defaults registerDefaults:defaultsDictionary];
}

#pragma mark - Max Concurrent Download Operation Count

- (NSUInteger)maxConcurrentDownloadCount
{
    return [self.defaults integerForKey:TCMaxConcurrentDownloadCountDefaultsKey];
}

- (void)setMaxConcurrentDownloadCount:(NSUInteger)maxConcurrentDownloadCount
{
//    [self willChangeValueForKey:@"maxConcurrentDownloadCount"];

    [self.defaults setInteger:maxConcurrentDownloadCount
                       forKey:TCMaxConcurrentDownloadCountDefaultsKey];

//    [self didChangeValueForKey:@"maxConcurrentDownloadCount"];
}

#pragma mark - Downloads Directory URL

- (NSURL *)downloadsDirectoryURL
{
    return [self.defaults URLForKey:TCDownloadsDirectoryURLDefaultsKey];
}

- (void)setDownloadsDirectoryURL:(NSURL *)downloadsDirectoryURL
{
//    [self willChangeValueForKey:@"downloadsDirectoryURL"];

    [self.defaults setURL:downloadsDirectoryURL
                   forKey:TCDownloadsDirectoryURLDefaultsKey];

//    [self didChangeValueForKey:@"downloadsDirectoryURL"];
}

@end
