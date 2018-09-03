//
//  NSMultitaskDownloader.h

//
//  Created by Developer on 2018/8/29.
//  Copyright © 2018 Developer. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const NSMultitaskDownloaderProgress;
extern NSString * const NSMultitaskDownloaderProgressURL;
extern NSString * const NSMultitaskDownloaderProgressValue;

@interface NSMultitaskDownloader : NSObject
+ (instancetype)shared;
- (void)downloadDataWithUrl:(NSString*)url progress:(void (^)(float downloadProgress))progress;
- (void)cancelTaskWithURL:(NSString*)url;
- (void)endBackgroundTaskWithIdentifier:(NSString *)identifier completion:(void (^)(NSURLSession *session))completion;

- (void)downloadURLs:(NSArray<NSString*>*)urls;
- (void)cancelAllTasks;
@end
