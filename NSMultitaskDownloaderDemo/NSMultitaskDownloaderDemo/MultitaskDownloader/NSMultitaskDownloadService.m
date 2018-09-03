//
//  NSMultitaskDownloadService.m

//
//  Created by Developer on 2018/8/31.
//  Copyright © 2018 Developer. All rights reserved.
//

#import "NSMultitaskDownloadService.h"

NSString * const NSMultitaskDownloadServiceResumeDataFileName = @"com.multitask.resumeDataFile.plist";
NSString * const NSMultitaskDownloaderProgress = @"com.multitask.NSMultitaskDownloadService.NSMultitaskDownloaderProgress";
NSString * const NSMultitaskDownloaderProgressURL = @"com.multitask.NSMultitaskDownloadService.NSMultitaskDownloaderProgressObjectKey";
NSString * const NSMultitaskDownloaderProgressValue = @"com.multitask.NSMultitaskDownloadService.NSMultitaskDownloaderProgressObjectValue";

@interface NSMultitaskDownloadService ()

@end

@implementation NSMultitaskDownloadService

- (instancetype)initWithURL:(NSString *)url {
    if (self = [super init]) {
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:url];
        configuration.timeoutIntervalForRequest = 30;
        configuration.allowsCellularAccess = YES;
        AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        _manager = manager;
        _url = url;
        
        [self activeNotification];
    }
    return self;
}

- (void)startDownloading {
    NSData* resumeData = [[NSUserDefaults standardUserDefaults] objectForKey:self.url];
    if (!resumeData) {
        [self startDownloadingData];
    }else {
        [self startResumingData:resumeData];
    }
}

- (void)stopDownloading {
    for (NSURLSessionDownloadTask* task in [self.manager downloadTasks]) {
        if ([task.currentRequest.URL.absoluteString isEqualToString:self.url] ) {
            if (task.state == NSURLSessionTaskStateRunning) {
                [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                }];
            }
            break;
        }
    }
}

- (BOOL)isDownloading {
    BOOL value = NO;
    for (NSURLSessionDownloadTask* task in [self.manager downloadTasks]) {
        if ([task.currentRequest.URL.absoluteString isEqualToString:self.url] ) {
            if (task.state == NSURLSessionTaskStateRunning) {
                value = YES;
            }
            break;
        }
    }
    return value;
}

#pragma mark - private

- (void)startDownloadingData {
    NSURLSessionDownloadTask* task = [self.manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]] progress:^(NSProgress * _Nonnull downloadProgress) {
        
        CGFloat currentProgress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        
        if (self.progressHandler) {
            self.progressHandler(currentProgress);
        }
        NSLog(@"url----> %@ /n %F",self.url, currentProgress);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NSMultitaskDownloaderProgress object:nil userInfo:@{NSMultitaskDownloaderProgressURL : self.url,
                                                                                                                       NSMultitaskDownloaderProgressValue : @(currentProgress)}];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.url.lastPathComponent]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", filePath);
        }
    }];
    [task resume];
}

- (void)startResumingData:(NSData*)resumeData {
    NSURLSessionDownloadTask* task = [self.manager downloadTaskWithResumeData:resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
        CGFloat currentProgress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        
        if (self.progressHandler) {
            self.progressHandler(currentProgress);
        }
        NSLog(@"url----> %@ /n %F",self.url, currentProgress);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NSMultitaskDownloaderProgress object:nil userInfo:@{NSMultitaskDownloaderProgressURL : self.url,
                                                                                                                       NSMultitaskDownloaderProgressValue : @(currentProgress)}];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:self.url.lastPathComponent]];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", filePath);
        }
    }];
    [task resume];
}

#pragma mark - handle AFNetworkingTaskDidCompleteNotification

- (void)activeNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEvent:) name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)handleEvent:(NSNotification*)notification {
    if ([notification.object isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURLSessionDownloadTask* task = notification.object;
        NSString* url = task.currentRequest.URL.absoluteString;
        
        if ([url isEqualToString:self.url]) {
            NSError* error = [notification.userInfo objectForKey:AFNetworkingTaskDidCompleteErrorKey];
            if (error) {
                NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
                [self saveResumeData:resumeData url:self.url];

            }else {
                [self removeResumeDataWithURL:url];
                [self stopDownloading];
            }
            NSLog(@"handleEvent: url -----> %@  state -----> %@, error -----> %@", url, @(task.state), error);
        }
        
    }
}

#pragma mark - save resume data

- (void)saveResumeData:(NSData*)data url:(NSString*)url {
    if (url && data) {
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:data forKey:url];
        [userDefaults synchronize];
    }
}

- (void)removeResumeDataWithURL:(NSString*)url {
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:url];
    [userDefaults synchronize];
}

@end
