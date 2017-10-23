//
//  SYShopCarBtn.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYShopCarBtn : UIButton
/** 购物车的商品数目 */
@property (nonatomic,assign) NSInteger goodsCounts;
+ (instancetype)defalutBtn;
@end
