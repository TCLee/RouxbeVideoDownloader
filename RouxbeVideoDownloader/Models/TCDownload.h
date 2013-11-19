//
//  TCDownload.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

typedef void(^TCDownloadDidCompleteBlock)(NSURL *fileURL, NSError *error);
typedef void(^TCDownloadDidChangeProgressBlock)(NSProgress *progress);

/**
 * \c TCDownload class describes a download task.
 */
@interface TCDownload : NSObject

/**
 * The directory URL that all the file downloads will be saved to.
 * 
 * By default, the download directory URL is set to the user's Downloads 
 * directory. You can set it to your own custom directory URL.
 */
@property (nonatomic, copy) NSURL *downloadDirectoryURL;

/**
 * The string that will be displayed as the title for this download.
 */
@property (nonatomic, copy, readonly) NSString *name;

/**
 * The URL of the resource to download.
 */
@property (nonatomic, copy, readonly) NSURL *sourceURL;

/**
 * The destination URL to save the downloaded file to.
 */
@property (nonatomic, copy, readonly) NSURL *destinationURL;

/**
 * The current progress of the download.
 *
 * When the progress has been updated, the TCDownload::didChangeProgress 
 * block will be called.
 */
@property (nonatomic, strong, readonly) NSProgress *progress;

@property (nonatomic, copy, readwrite) TCDownloadDidChangeProgressBlock didChangeProgress;
@property (nonatomic, copy, readwrite) TCDownloadDidCompleteBlock didComplete;

- (id)initWithSourceURL:(NSURL *)sourceURL
              groupName:(NSString *)groupName
               position:(NSUInteger)position
                   name:(NSString *)name;

//- (id)initWithSourceURL:(NSURL *)sourceURL
//                   name:(NSString *)fileName;

/**
 * Creates and starts the download task.
 *
 * The TCDownload::didChangeProgress block will be called when the download
 * has made progress.
 * The TCDownload::didComplete block will be called when the download
 * has completed.
 *
 * @return The download task that is currently running.
 */
- (NSURLSessionDownloadTask *)start;

@end
