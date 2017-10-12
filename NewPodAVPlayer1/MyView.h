//
//  MyView.h
//  IJKCoCo
//
//  Created by 吕超 on 2017/10/9.
//  Copyright © 2017年 MAXTV. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyviewDelegate.h"


@interface MyView : UIView

-(void)play;
-(void)stop;
-(void)replaceAsetWithUrl:(NSString *)URL;

@property (nonatomic ,weak) id<MyviewDelegate> delegate;


@end
