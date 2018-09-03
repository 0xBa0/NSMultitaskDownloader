//
//  NSMultitaskDownloadService.h

//
//  Created by Developer on 2018/8/31.
//  Copyright © 2018 Developer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

typedef void(^NSMultitaskDownloadServiceProgressHandler)(float progress);

@interface NSMultitaskDownloadService : NSObject
@property (nonatomic, strong, readonly) NSString* url;
@property (nonatomic, strong, readonly) AFURLSessionManager* manager;
@property (nonatomic, assign, readonly) BOOL isDownloading;
@property (nonatomic, copy) NSMultitaskDownloadServiceProgressHandler progressHandler;
- (instancetype)initWithURL:(NSString*)url;
- (void)startDownloading;
- (void)stopDownloading;
@end
