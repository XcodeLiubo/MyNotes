//
//  SYUserInfoCell.m
//  个人中心
//
//  Created by Liubo on 2017/10/4.
//  Copyright © 2017年 LB. All rights reserved.
//

#import "SYUserInfoCell.h"
#import <objc/runtime.h>


@implementation UIButton (IconUP)
//- (void)myBtnSubViewLayout{
//    [self myBtnSubViewLayout];  //会返回去调用 _contentBtn的layoutsubviews方法
//
//    [self.titleLabel sizeToFit];
//    CGFloat titleh = self.titleLabel.frame.size.height;
//    CGFloat titlew = self.titleLabel.frame.size.width;
//    CGFloat imagew = self.imageView.frame.size.width;
//    CGFloat imageh = self.imageView.frame.size.height;
//    CGFloat btnw = self.frame.size.width;
//    CGFloat btnh = self.frame.size.height;
//
//    CGFloat imageViewbeginx = (btnw - imagew) / 2;
//    CGFloat imageViewbeginy = (btnh - imageh - titleh) / 2;
//    CGFloat titlebeginx = (btnw - titlew) / 2;
//    CGFloat titlebeginy = imageh + imageViewbeginy;
//    self.imageView.frame = CGRectMake(imageViewbeginx, imageViewbeginy, imagew, imageh);
//    self.titleLabel.frame = CGRectMake(titlebeginx, titlebeginy, titlew, titleh);
//
//}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.titleLabel sizeToFit];
    CGFloat titleh = self.titleLabel.frame.size.height;
    CGFloat titlew = self.titleLabel.frame.size.width;
    CGFloat imagew = self.imageView.frame.size.width;
    CGFloat imageh = self.imageView.frame.size.height;
    CGFloat btnw = self.frame.size.width;
    CGFloat btnh = self.frame.size.height;
    
    CGFloat imageViewbeginx = (btnw - imagew) / 2;
    CGFloat imageViewbeginy = (btnh - imageh - titleh) / 2;
    CGFloat titlebeginx = (btnw - titlew) / 2;
    CGFloat titlebeginy = imageh + imageViewbeginy;
    self.imageView.frame = CGRectMake(imageViewbeginx, imageViewbeginy, imagew, imageh);
    self.titleLabel.frame = CGRectMake(titlebeginx, titlebeginy, titlew, titleh);
}

@end



@interface SYUserInfoCell ()
/** button */
@property (nonatomic,strong) UIButton *contentBtn;

/** 数量 */
@property (nonatomic,strong) UILabel *totalsLab;
@end


//static Method _myCustomMethod, _systemMehtod;
@implementation SYUserInfoCell

//不要用交换 否则所有的 不管在不在这个界面创建的button 都会是这种布局 出非这个view死掉了  重写layoutsubview
//+ (void)load{
//    _myCustomMethod = class_getInstanceMethod([UIButton class], @selector(myBtnSubViewLayout));
//
//    _systemMehtod = class_getInstanceMethod([UIButton class], @selector(layoutSubviews));
//
//    method_exchangeImplementations(_systemMehtod, _myCustomMethod);
//}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setUPUI];
    }return self;
}

#pragma mark -- UI
- (void)setUPUI{
    _contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    _contentBtn.backgroundColor = [UIColor greenColor];
    _contentBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:12];
    [_contentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_contentBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [_contentBtn addTarget:self action:@selector(testtext:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_contentBtn];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    CGPoint p = [self convertPoint:point toView:_contentBtn];
    if ([_contentBtn pointInside:p withEvent:event]) {
        return self;
    }
    return [super hitTest:point withEvent:event];
    
}

- (void)setType:(CellPosition)type{
    _type = type;
    NSDictionary *dic = [self.delegate userInfoCellContents];
    NSString *key = dic.allKeys.firstObject;
    [_contentBtn setTitle:key forState:UIControlStateNormal];
    [_contentBtn setTitle:key forState:UIControlStateHighlighted];
    
    UIImage *image = [UIImage imageNamed:dic[key]];
    [_contentBtn setImage:image forState:UIControlStateNormal];
    [_contentBtn setImage:image forState:UIControlStateHighlighted];
}



#pragma mark --- runtime交换系统的方法 button的布局方法
- (void)layoutSubviews{
    [super layoutSubviews];
     _contentBtn.frame = self.contentView.bounds;
}


//- (void)dealloc{
//    method_exchangeImplementations(_systemMehtod, _myCustomMethod);
//    free(_systemMehtod);
//    free(_myCustomMethod);
//    _systemMehtod = nil;
//    _myCustomMethod = nil;
//}



@end
