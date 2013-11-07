//
//  TCVideoFile.h
//  RouxbeVideoDownloader
//
//  Created by Lee Tze Cheun on 11/7/13.
//  Copyright (c) 2013 Lee Tze Cheun. All rights reserved.
//

@class TCLessonStep;

@interface TCVideoFile : NSObject

/**
 * Returns the video filename.
 */
@property (nonatomic, copy, readonly) NSString *filename;

/**
 * Returns the name of the directory that was created to group this 
 * video file. Returns \c nil if video file does not need to be grouped.
 *
 * \b Example: Videos of each Lesson's step will be grouped under the
 * Lesson's directory. A Tip & Technique video has no need to be grouped,
 * so it will return \c nil for this property.
 */
@property (nonatomic, copy, readonly) NSString *directoryName;

/**
 * The URL of the directory that this video file and its 
 * group (if any) will be saved to.
 *
 * If this property is left \c nil, the video file will be saved to 
 * the user's default Downloads directory.
 */
@property (nonatomic, copy) NSURL *downloadDirectoryURL;

/**
 * Returns the file URL that references where this video file will be saved to.
 *
 * @return A \c NSURL object referencing the video file.
 */
- (NSURL *)fileURL;

/**
 * Returns an initialized \c TCVideoFile object that describes the given
 * lesson step's video file.
 *
 * @param lessonStep The \c TCLessonStep object will be used to
 *                   configure the video file properties.
 *
 * @return A \c TCVideoFile object describing \c lesson step's video file.
 */
- (id)initWithLessonStep:(TCLessonStep *)lessonStep;

@end
