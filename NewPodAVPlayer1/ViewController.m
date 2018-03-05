//
//  ViewController.m
//  NewPodAVPlayer1
//
//  Created by 吕超 on 2017/10/11.
//  Copyright © 2017年 MAXTV. All rights reserved.
//

#import "ViewController.h"
#import "MyView.h"
#import "AVHeader.h"

@interface ViewController ()<MyviewDelegate>

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    MyView * vv = [[MyView alloc] init];
    
    
    
    vv.delegate = self;
    [self.view addSubview:vv];
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    [vv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(0);
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(BOOL)prefersStatusBarHidden{
    return YES;// 返回YES表示隐藏，返回NO表示显示
}

-(void)zoomMyViewWithBigOrSamll:(MYViewBigOrSmall)aa{
    if (aa==MYViewBig) {
        MyView * vv = [self.view viewWithTag:100];
        vv.transform = CGAffineTransformMakeRotation(M_PI_2);
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        [vv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.mas_equalTo(height);
            make.height.mas_equalTo(width);
        }];
    }else if(aa ==MYViewSmall){
        MyView * vv = [self.view viewWithTag:100];
        vv.transform = CGAffineTransformMakeRotation(0);
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        [vv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view).with.offset(0);
            make.size.mas_equalTo(CGSizeMake(width, width/16*9));
        }];
    }
} 
-(void)backTheView{
    NSLog(@"返回按钮");
}
-(void)bbClickEd{//点击切换播放源
    MyView * vv = [self.view viewWithTag:100];
    [vv replaceAsetWithUrl:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"];
    [vv play];
}




@end
