//
//  SYShopCarBtn.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYShopCarBtn.h"
#import "SYShopCarVC.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"



@interface SYShopCarBtn()
/** 多少个商品*/
@property (nonatomic,weak) UILabel *countsLab;
@end


static SYShopCarBtn *_instance;
@implementation SYShopCarBtn

+ (instancetype)defalutBtn{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self buttonWithType:UIButtonTypeCustom];
        if(_instance){
            [_instance createUI];
            [_instance addTarget:_instance action:@selector(goShopCarVC) forControlEvents:UIControlEventTouchUpInside];
        }
    });
    return _instance;
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super buttonWithType:buttonType];
    });
    return _instance;
}


#pragma mark --- UI
- (void)createUI{
    UIImage *img = IMAGE(icon_shoppingCart);
    
    self.w = img.size.width;
    self.h = img.size.height;
    [self setImage:img forState:UIControlStateNormal];
    [self setImage:img forState:UIControlStateHighlighted];
    [self setTitle:@"1" forState:UIControlStateNormal];
    [self setTitle:@"1" forState:UIControlStateHighlighted];
    
    self.titleLabel.backgroundColor = COLOR(ff0000);
    self.titleLabel.layer.cornerRadius = 7.5;
    self.titleLabel.layer.masksToBounds = YES;
    self.titleLabel.textColor = COLOR(ffffff);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
}


- (void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.w = 15;
    self.titleLabel.h = 15;
    self.titleLabel.x = self.w - self.titleLabel.w * 0.5;
    self.titleLabel.y = -self.titleLabel.h * 0.5;
}

- (void)setGoodsCounts:(NSInteger)goodsCounts{
    if(goodsCounts == _goodsCounts)return;
    _goodsCounts = goodsCounts;
    [self setTitle:[NSString stringWithFormat:@"%zd",_goodsCounts] forState:UIControlStateNormal];
    [self setTitle:[NSString stringWithFormat:@"%zd",_goodsCounts] forState:UIControlStateHighlighted];
}


- (void)goShopCarVC{
    PostNoti(@"去购物车", nil);
}


@end



#pragma clang diagnostic pop
