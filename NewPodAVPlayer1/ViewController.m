//
//  ViewController.m
//  NewPodAVPlayer1
//
//  Created by 吕超 on 2017/10/11.
//  Copyright © 2017年 MAXTV. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"
#import "Masonry.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    MyView * vv = [[MyView alloc] init];
    [self.view addSubview:vv];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [vv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(60);
        make.size.mas_equalTo(CGSizeMake(width, width/16*9));
    }];
    vv.backgroundColor = [UIColor blackColor];
    [self.view addSubview:vv];
    [vv layoutSubviews];
    vv.tag=100;
    [vv play];
    
    
    UIButton * bb = [UIButton buttonWithType:UIButtonTypeCustom];
    [bb addTarget:self action:@selector(bbClickEd) forControlEvents:UIControlEventTouchUpInside];
    bb.backgroundColor = [UIColor redColor];
    bb.frame = CGRectMake(100, 500, 30, 30);
    [self.view addSubview:bb];
    
    
}
-(void)bbClickEd{
    MyView * vv = [self.view viewWithTag:100];
    [vv replaceAsetWithUrl:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    [vv play];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft ;
}
-(void)changeRotate:(NSNotification *)noti{
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        NSLog(@"竖屏");
    } else {
        //横屏
        NSLog(@"横屏");
    }
}


@end
