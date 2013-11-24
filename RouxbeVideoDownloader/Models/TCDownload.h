//
//  TCDownload.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCVideo;
@class TCDownload;

typedef void(^TCDownloadCompletionHandler)(NSArray *downloads, NSError *error);

/**
 * Constants for determining the current state of a download.
 */
typedef NS_ENUM(NSInteger, TCDownloadState) {
    /**
     * The download is currently in progress.
     */
    TCDownloadStateRunning = 0,
    /**
     * The download has been paused.
     */
    TCDownloadStatePaused = 1,
    /**
     * The download has failed with an error.
     */
    TCDownloadStateFailed = 2,
    /**
     * The download has completed successfully.
     */
    TCDownloadStateCompleted = 3,
};

/**
 * \c TCDownload class is responsible for downloading a video.
 */
@interface TCDownload : NSObject

/**
 * The URL to the directory that all the video files will be saved to.
 * 
 * This directory will be decided by the user, but it cannot be \c nil.
 */
@property (nonatomic, copy, readonly) NSURL *downloadDirectoryURL;

/**
 * The string that is intended for display on a view.
 */
@property (nonatomic, copy, readonly) NSString *description;

/**
 * The source URL to download the video from.
 */
@property (nonatomic, copy, readonly) NSURL *sourceURL;

/**
 * The destination URL to save the downloaded video file to.
 *
 * The destination URL is created by appending to the user provided 
 * download directory.
 *
 * @see TCDownload::downloadDirectoryURL
 */
@property (nonatomic, copy, readonly) NSURL *destinationURL;

/**
 * The current progress of the download.
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

/**
 * The current state of the download.
 */
@property (nonatomic, assign, readonly) TCDownloadState state;

/**
 * An error object that indicates why the download failed.
 *
 * This value is \c nil, if no error was encountered.
 */
@property (nonatomic, copy, readonly) NSError *error;

/**
 * <#Description#>
 *
 * @param video                <#video description#>
 * @param downloadDirectoryURL <#downloadDirectoryURL description#>
 * @param description          <#description description#>
 *
 * @return <#return value description#>
 */
- (id)initWithVideo:(TCVideo *)video
downloadDirectoryURL:(NSURL *)downloadDirectoryURL
        description:(NSString *)description;

- (id)initWithSourceURL:(NSURL *)sourceURL
         destinationURL:(NSURL *)destinationURL
            description:(NSString *)description;

/**
 * <#Description#>
 *
 * @param theURL            <#theURL description#>
 * @param completionHandler <#completionHandler description#>
 */
+ (void)downloadsWithURL:(NSURL *)theURL
       completionHandler:(TCDownloadCompletionHandler)completionHandler;

/**
 * <#Description#>
 *
 * @param theURL               <#theURL description#>
 * @param downloadDirectoryURL <#downloadDirectoryURL description#>
 * @param completionHandler    <#completionHandler description#>
 */
+ (void)downloadsWithURL:(NSURL *)theURL
    downloadDirectoryURL:(NSURL *)downloadDirectoryURL
       completionHandler:(TCDownloadCompletionHandler)completionHandler;

/**
 * Return the user's default Downloads directory or \c nil if not found.
 *
 * This will be the directory used to store the downloads, if you 
 * do not specify a directory.
 */
+ (NSURL *)userDownloadsDirectoryURL;

@end
