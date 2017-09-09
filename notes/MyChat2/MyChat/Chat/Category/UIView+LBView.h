//
//  UIView+LBView.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/8.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (LBView)

#define BasicProperty
/** x*/
@property(nonatomic,assign) CGFloat x;

/** y*/
@property(nonatomic,assign) CGFloat y;

/** width*/
@property(nonatomic,assign) CGFloat w;

/** height*/
@property(nonatomic,assign) CGFloat h;

/** center X*/
@property(nonatomic,assign) CGFloat c_x;

/** center y*/
@property(nonatomic,assign) CGFloat c_y;

/** max X*/
@property(nonatomic,assign,readonly) CGFloat m_x;

/** max Y*/
@property(nonatomic,assign,readonly) CGFloat m_y;

/** size*/
@property(nonatomic,assign,readonly) CGSize size;

/** 标识*/
@property(nonatomic,assign,readonly) NSString *identifyID;

#define quicklyCreateView
+ (instancetype)createView:(void (^)(__kindof UIView *view))viewMaker;



#define 链式
#define 初始化的时候设置    ;
#define viewDecrption    初始化的时候设置
#define init_Frame       viewDecrption
#define     init_X       viewDecrption
#define     init_Y       viewDecrption
#define     init_W       viewDecrption
#define     init_H       viewDecrption
#define  init_中心C       viewDecrption
#define  init_中心X       viewDecrption
#define  init_中心Y       viewDecrption
#define init_背景颜色      viewDecrption
#define    init_标识      viewDecrption

- (__kindof UIView * (^)(CGRect      value))     init_frame          init_Frame

- (__kindof UIView * (^)(CGFloat     value))         init_x          init_X

- (__kindof UIView * (^)(CGFloat     value))         init_y          init_Y

- (__kindof UIView * (^)(CGFloat     value))         init_w          init_W

- (__kindof UIView * (^)(CGFloat     value))         init_h          init_H

- (__kindof UIView * (^)(CGFloat     value))       init_c_x          init_中心X

- (__kindof UIView * (^)(CGFloat     value))       init_c_y          init_中心Y

- (__kindof UIView * (^)(CGPoint     value))         init_c          init_中心C

- (__kindof UIView * (^)(UIColor    *value))   init_bgColor          init_背景颜色

- (__kindof UIView * (^)(NSString   *value))  init_identify          init_标识

/** 根据标识找到控件控件*/
+ (__kindof UIView *)viewWithIdentify:(NSString * const)identify;


/** 快速创建一个圆角的view*/
+ (instancetype)roundViewWithRadius:(CGFloat)radius bgColor:(UIColor *)bgColor rect:(CGRect)rect;
@end
