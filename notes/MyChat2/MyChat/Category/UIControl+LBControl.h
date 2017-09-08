//
//  UIControl+LBControl.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/8.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ControlBlock)(UIControl *value);
@interface UIControl (LBControl)
/** 回调的block*/
@property(nonatomic,copy) ControlBlock actionBlock;

/** 点击的回调*/
- (instancetype(^)(ControlBlock value))block;
@end
