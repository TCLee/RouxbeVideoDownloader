//
//  TCDownload.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

/**
 * \c TCDownload class describes a video download in progress.
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
 * The title string that will be displayed for this download.
 */
@property (nonatomic, copy, readonly) NSString *title;

@property (nonatomic, copy, readonly) NSURL *sourceURL;
@property (nonatomic, copy, readonly) NSURL *destinationURL;
@property (nonatomic, copy, readonly) NSProgress *progress;

- (id)initWithSourceURL:(NSURL *)sourceURL
              groupName:(NSString *)groupName
               position:(NSUInteger)position
                   name:(NSString *)name;

//- (id)initWithSourceURL:(NSURL *)sourceURL
//               fileName:(NSString *)fileName;

//- (void)startWithCompletion:(void (^)(NSURL *fileURL , NSError *error))completion;

@end
