//
//  MyviewDelegate.h
//  NewPodAVPlayer1
//
//  Created by 吕超 on 2017/10/11.
//  Copyright © 2017年 MAXTV. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MYViewBigOrSmall){
    MYViewBig,
    MYViewSmall,
    
};


@protocol MyviewDelegate <NSObject>

@required
-(void)zoomMyViewWithBigOrSamll:(MYViewBigOrSmall)aa;
@optional
-(void)backTheView;

@end
