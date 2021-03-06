//
//  MyView.m
//  IJKCoCo
//
//  Created by 吕超 on 2017/10/9.
//  Copyright © 2017年 MAXTV. All rights reserved.
//

#import "MyView.h"
#import <AVFoundation/AVFoundation.h>
#import "AVHeader.h"



@interface MyView ()<MBProgressHUDDelegate>
@property (nonatomic ,strong) AVPlayer * player;
@property (nonatomic ,strong) AVURLAsset * playerAsset;
@property (nonatomic ,strong) AVPlayerItem * playerItem;
@property (nonatomic ,strong) AVPlayerLayer * playerLayer;
@property (nonatomic ,assign) CGFloat fps;

@property (strong, nonatomic) id timeObserver;                      //视频播放时间观察者
@property (nonatomic ,strong) UITapGestureRecognizer * tap;

//xib创建的遮盖层
@property (strong, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;//缓存进度条
@property (weak, nonatomic) IBOutlet UILabel *currentTime;//当前时间
@property (weak, nonatomic) IBOutlet UILabel *totalTime;//总时间
@property (weak, nonatomic) IBOutlet UISlider *playProgress;//播放进度条



@end

@implementation MyView

-(instancetype)init{
    self = [super init];
    if (self) {
        self.playerAsset=[[AVURLAsset alloc]initWithURL:[NSURL URLWithString:@"http://download.3g.joy.cn/video/236/60236937/1451280942752_hd.mp4"] options:nil];
        _fps = [[[self.playerAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
        self.playerItem=[AVPlayerItem playerItemWithAsset:self.playerAsset];

        self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
        self.playerLayer = [[AVPlayerLayer alloc] init];
        self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;

        self.playerLayer.frame = CGRectMake(0, 0, 320, 180);
        [self.playerLayer displayIfNeeded];
        [self.layer insertSublayer:self.playerLayer atIndex:0];
        [self addKVO];
        MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:hud];
        hud.dimBackground = YES;
        hud.labelText = @"请稍等";
        [hud show:YES];
        
        _coverView = [[NSBundle mainBundle] loadNibNamed:@"BigAndSmall" owner:self options:nil].lastObject;
        [self addSubview:_coverView];
        _coverView.backgroundColor = [UIColor colorWithRed:53/255.0f green:53/255.0f blue:53/255.0f alpha:0.3];
        [self.playProgress setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
        [self.playProgress setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateHighlighted];
        
        //拖动时候触发的方法
        [self.playProgress addTarget:self action:@selector(handleTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self.playProgress addTarget:self action:@selector(handleSlide:) forControlEvents:UIControlEventValueChanged];
        [self.playProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self.playProgress addTarget:self action:@selector(handleTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
         _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
        [_tap setNumberOfTouchesRequired:1];//一个手指
        [self.playProgress addGestureRecognizer:_tap];//给slider加一个手势 获得当前点击的位置
        
        
    }
    return self;
}
-(void)play{
    [self.player play];
}
-(void)pause{
    [self.player pause];
}
- (IBAction)back:(id)sender {
    if ([self.delegate respondsToSelector:@selector(backTheView)]) {
        [self.delegate backTheView];
    }
}
- (IBAction)zoomTheView:(id)sender {
    UIButton * bb = (UIButton *)sender;
    bb.selected = !bb.selected;
    if (bb.selected) {
        if ([self.delegate respondsToSelector:@selector(zoomMyViewWithBigOrSamll:)]) {
            [self.delegate zoomMyViewWithBigOrSamll:MYViewSmall];
        }
    }else{
        if ([self.delegate respondsToSelector:@selector(zoomMyViewWithBigOrSamll:)]) {
            [self.delegate zoomMyViewWithBigOrSamll:MYViewBig];
        }
    }
}



-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    _coverView.frame = self.bounds;
}
-(void)newPlay{
    self.playerAsset=[[AVURLAsset alloc]initWithURL:[NSURL URLWithString:@"http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8"] options:nil];
    self.playerItem=[AVPlayerItem playerItemWithAsset:self.playerAsset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    self.playerLayer.frame = CGRectMake(0, 0, 320, 180);
    [self.playerLayer displayIfNeeded];
    [self.layer insertSublayer:self.playerLayer atIndex:0];
    [self addKVO];
    
    [self.player play];
}
-(void)stop{
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeTimeObserver:self.timeObserver];
   
    if (self.player) {
        [self.player pause];
        self.playerAsset = nil;
        self.playerItem = nil;
        self.player = nil;
        
    }
}
-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    self.playerLayer.player = self.player;
}


//添加KVO
-(void)addKVO{
    //监听状态属性
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监听网络加载情况属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    //监听播放的区域缓存是否为空
    [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
    //缓存可以播放的时候调用
    [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    //监听暂停或者播放中
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
    //这里设置每秒执行一次
    __weak __typeof(self) weakself = self;
    self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        NSInteger current = CMTimeGetSeconds(time);
        if (current) {
            weakself.currentTime.text = [NSString stringWithFormat:@"%@",[weakself convertTime:current]];
            weakself.playProgress.value = CMTimeGetSeconds(weakself.player.currentItem.currentTime)/CMTimeGetSeconds(weakself.player.currentItem.duration);
            
        }
    }];
    
}
//将数值转换成时间
- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}
#pragma mark -MBProgressHUD的delegate
-(void)hudWasHidden:(MBProgressHUD *)hud{
    [hud removeFromSuperview];
    hud = nil;
}
#pragma mark -slider的点击事件
- (void)handleTouchDown:(UISlider *)slider{
    NSLog(@"TouchDown");
    _tap.enabled = NO;
    [_player pause];

}

- (void)handleTouchUp:(UISlider *)slider{
    NSLog(@"TouchUp");
    _tap.enabled = YES;

    [_player play];

}

- (void)handleSlide:(UISlider *)slider{
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.playerItem.asset.duration) * slider.value, _fps);
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"Tap");
    CGPoint touchPoint = [recognizer locationInView:self.playProgress];//获得手势点
    CGFloat value = touchPoint.x / CGRectGetWidth(self.playProgress.frame);
    [self.playProgress setValue:value animated:YES];


        [_player pause];

    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.playerItem.asset.duration) * value, _fps);//当前手指点击的位置的time
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {

            [_player play];

    }];
}
//TODO: KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus itemStatus = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        switch (itemStatus) {
            case AVPlayerItemStatusUnknown:
            {
                //播放的工具处于未知状态
                NSLog(@"AVPlayerItemStatusUnknown");
            }
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                NSInteger totalSeconds =  CMTimeGetSeconds(self.playerItem.duration);
                if (totalSeconds>0) {
                    self.totalTime.text = [self convertTime:totalSeconds];
                }else{
                    self.totalTime.text = @"--:--";
                }
                
                NSLog(@"%ld------",totalSeconds);
                //播放的工具处于准备播放的状态
                NSLog(@"AVPlayerItemStatusReadyToPlay");
            }
                break;
            case AVPlayerItemStatusFailed:
            {
                //播放的工具的播放失败状态
                NSLog(@"AVPlayerItemStatusFailed");
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度（可以在这里计算缓冲的进度 和获得视频的总大小，做进度条）
        NSArray *loadedTimeRanges = [self.playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        //缓存值
        self.progressView.progress = timeInterval/totalDuration;
        NSInteger ppp = CMTimeGetSeconds([self.player currentTime]);
        NSLog(@"%ld==-----",ppp);
        //（无论直播还是重播，都是在这儿缓存视频，缓存好视频以后播放）
    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态(缓冲数据为空，而且有效时间内数据无法补充，播放失败)
        NSLog(@"1111111");
        MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:hud];
        hud.dimBackground = YES;
        hud.labelText = @"请稍等";
        [hud show:YES];
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {//seekToTime后,可以正常播放，相当于readyToPlay，一般拖动滑竿菊花转，到了这个这个状态菊花隐藏
        NSLog(@"222222");
         [MBProgressHUD hideAllHUDsForView:self animated:YES];
    } else if ([keyPath isEqualToString:@"rate"]){//当rate==0时为暂停,rate==1时为播放,当rate等于负数时为回放
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue]==0) {
            NSLog(@"暂停了");
        }else{
            NSLog(@"播放");
        }
    }else if([keyPath isEqualToString:@"currentTime"]){
        if ([[change objectForKey:NSKeyValueChangeNewKey]integerValue]==0) {
            NSLog(@"在改变");
        }else{
            NSLog(@"没有改变");
        }
    }
}
-(void)replaceAsetWithUrl:(NSString *)URL{
    self.playerAsset = nil;
    self.playerAsset=[[AVURLAsset alloc]initWithURL:[NSURL URLWithString:URL] options: @{ AVURLAssetPreferPreciseDurationAndTimingKey : @YES }];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    self.playerItem = nil;
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:self.playerAsset];
    [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    [self.playerLayer displayIfNeeded];
    [self addKVO];
    [self play];
    
}
-(void)dealloc{
    NSLog(@"销毁了");
}
@end
