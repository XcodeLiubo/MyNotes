//
//  RRJJButton.h
//  newrrjj
//
//  Created by   LiuBo on 2017/8/27.
//  Copyright © 2017年 lll. All rights reserved.
//




#import <UIKit/UIKit.h>
typedef void(^Btnlock)(id obj);

@interface RRJJButton : UIButton

+ (instancetype)buttonWithIdentify:(NSString *)identify;


/** 点击的回调*/
@property(nonatomic,copy) Btnlock block;

/** 标识*/
@property(nonatomic,copy,readonly) NSString *identify;







#define TITLE
#define IMG
#define BGIMG
#define IDENTIFY
#define BGCOLOR
#define CLICK_BTN
/** title 注意将state包装成 NSNumber*/
- (RRJJButton *(^)(NSString *title, UIControlState state, ...))title    TITLE;

/** image*/
- (RRJJButton *(^)(UIImage *image, UIControlState state))img            IMG;


/** 背景图片*/
- (RRJJButton *(^)(UIImage *image, UIControlState state))bgImg          BGIMG;

/** 标识*/
- (RRJJButton *(^)(NSString *identify))ID                               IDENTIFY;

/** 背景颜色*/
- (RRJJButton *(^)(UIColor *bgColor))bgColor                            BGCOLOR;

/** 回调*/
- (RRJJButton *(^)(Btnlock clickBtn))clickBtn                           CLICK_BTN;


+ (instancetype)rrjjBtnMaker:(void(^)(RRJJButton *button))maker;
@end
