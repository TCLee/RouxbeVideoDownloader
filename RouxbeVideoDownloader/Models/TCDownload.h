//
//  TCDownload.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCVideo;
@class TCDownload;

/**
 * The signature for the block object that will be called when 
 * the array of downloads have been created (or an error occured).
 *
 * @param downloads The array of downloads or \c nil on error.
 * @param error     An \c NSError object on error or \c nil on success.
 */
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
     * All downloads start in the paused state.
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
 * \c TCDownload class describes a video download.
 */
@interface TCDownload : NSObject

/**
 * The source URL to download the video from.
 */
@property (nonatomic, copy, readonly) NSURL *sourceURL;

/**
 * The destination URL to save the downloaded video file to.
 */
@property (nonatomic, copy, readonly) NSURL *destinationURL;

/**
 * The string that is intended for display on a view.
 */
@property (nonatomic, copy, readonly) NSString *description;

/**
 * The current progress of the download.
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

/**
 * The \c NSURLSessionDownloadTask that performs the actual download.
 */
@property (nonatomic, strong, readonly) NSURLSessionDownloadTask *task;

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
 * Initializes a new download with the given source URL, destination URL 
 * and description string to display on a view.
 *
 * @param sourceURL      The source URL.
 * @param destinationURL The destination URL to save the downloaded file.
 * @param description    The description string to display on a view.
 *
 * @return An initialized \c TCDownload object.
 */
- (id)initWithSourceURL:(NSURL *)sourceURL
         destinationURL:(NSURL *)destinationURL
            description:(NSString *)description;

/**
 * Creates and returns an array of downloads from the given URL. The downloads
 * will be saved to the specified downloads directory.
 *
 * This method will first search for all available videos from the given
 * URL. For each video it finds, it will create a download for the video.
 * Finally, it will call the completion handler with the array of downloads
 * (or an \c NSError object, if an error occured).
 *
 * @param theURL               The URL to find videos and create downloads for.
 * @param downloadDirectoryURL The directory URL to save the downloads to.
 * @param completionHandler    A block object to call when downloads have 
 *                             been created or an error occured.
 */
+ (void)downloadsWithURL:(NSURL *)theURL
    downloadDirectoryURL:(NSURL *)downloadDirectoryURL
       completionHandler:(TCDownloadCompletionHandler)completionHandler;

@end
