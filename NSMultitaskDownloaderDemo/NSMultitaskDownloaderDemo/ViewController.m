//
//  ViewController.m

//
//  Created by Developer on 2018/8/29.
//  Copyright © 2018 Developer. All rights reserved.
//

#import "ViewController.h"
#import "NSMultitaskDownloader.h"

NSString * const URL_0 = @"https://download-ssl.firefox.com.cn/releases/firefox/61.0/zh-CN/Firefox-latest.dmg";
NSString * const URL_1 = @"https://download-ssl.firefox.com.cn/releases/firefox/61.0/zh-CN/Firefox-latest.tar.bz2";
NSString * const URL_2 = @"https://download-ssl.firefox.com.cn/releases/mobile/61.0/zh-CN/Firefox-Android-61.0.apk";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView_0;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView_1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView_2;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLable_0;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLable_1;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLable_2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)downloadAllDatas:(id)sender {
    [[NSMultitaskDownloader shared] downloadURLs:@[URL_0, URL_1, URL_2]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadprogress:) name:NSMultitaskDownloaderProgress object:nil];
}

- (void)downloadprogress:(NSNotification*)notification {
    NSLog(@"%@", notification);
    
}

- (IBAction)cancelAllTasks:(id)sender {
    [[NSMultitaskDownloader shared] cancelAllTasks];
}

- (IBAction)download_0:(id)sender {
    __block typeof(self) weak_self = self;
    self.fileNameLable_0.text = URL_0.lastPathComponent;
    [[NSMultitaskDownloader shared] downloadDataWithUrl:URL_0 progress:^(float downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.progressView_0.progress = downloadProgress;
        });
    }];
}
- (IBAction)suspend_0:(id)sender {
    [[NSMultitaskDownloader shared] cancelTaskWithURL:URL_0];
}

- (IBAction)download_1:(id)sender {
    __block typeof(self) weak_self = self;
    self.fileNameLable_1.text = URL_1.lastPathComponent;
    [[NSMultitaskDownloader shared] downloadDataWithUrl:URL_1 progress:^(float downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.progressView_1.progress = downloadProgress;
        });
    }];
}
- (IBAction)suspend_1:(id)sender {
    [[NSMultitaskDownloader shared] cancelTaskWithURL:URL_1];
}

- (IBAction)download_2:(id)sender {
    __block typeof(self) weak_self = self;
    self.fileNameLable_2.text = URL_2.lastPathComponent;
    [[NSMultitaskDownloader shared] downloadDataWithUrl:URL_2 progress:^(float downloadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.progressView_2.progress = downloadProgress;
        });
    }];
}
- (IBAction)suspend_2:(id)sender {
    [[NSMultitaskDownloader shared] cancelTaskWithURL:URL_2];
}

@end
