//
//  DownloadManager.m
//  TestForArchive
//
//  Created by Developer on 2018/8/29.
//  Copyright © 2018 Developer. All rights reserved.
//

#import "NSMultitaskDownloader.h"
#import "NSMultitaskDownloadService.h"



#pragma mark - NSMultitaskDownloader
@interface NSMultitaskDownloader ()
@property (nonatomic, strong) NSMutableArray<NSMultitaskDownloadService*>* services;
@end

@implementation NSMultitaskDownloader

#pragma mark - init

static NSMultitaskDownloader *tool = nil;
+ (instancetype)shared{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool =  [[self alloc] init];
    });
    return tool;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.services = [NSMutableArray<NSMultitaskDownloadService*> array];
    }
    return self;
}

#pragma mark - download session

- (void)downloadDataWithUrl:(NSString*)url progress:(void (^)(float))progress{
    NSMultitaskDownloadService* service = [self getServiceWithURL:url];
    if (!service) {
        service = [[NSMultitaskDownloadService alloc] initWithURL:url];
        service.progressHandler = progress;
        [self.services addObject:service];
    }else if (service.isDownloading) {
        service.progressHandler = progress;
        return;
    }
    
    [service startDownloading];
}

- (void)cancelTaskWithURL:(NSString*)url {
    NSMultitaskDownloadService* service = [self getServiceWithURL:url];
    [service stopDownloading];
}

- (void)downloadURLs:(NSArray<NSString *> *)urls {
    for (NSString* url in urls) {
        [self downloadDataWithUrl:url progress:^(float downloadProgress) {
            
        }];
    }
}
- (void)cancelAllTasks {
    for (NSMultitaskDownloadService* service in self.services) {
        [service stopDownloading];
    }
}

#pragma mark - endBackgroundTask

- (void)endBackgroundTaskWithIdentifier:(NSString *)identifier completion:(void (^)(NSURLSession *))completion{
    NSMultitaskDownloadService* service = [self getServiceWithURL:identifier];
    if (service) {
        [service.manager setDidFinishEventsForBackgroundURLSessionBlock:completion];
    }
}

#pragma mark - private

- (NSMultitaskDownloadService*)getServiceWithURL:(NSString*)url {
    for (NSMultitaskDownloadService* service in self.services) {
        if ([service.url isEqualToString:url]) {
            return service;
        }
    }
    return nil;
}

@end
