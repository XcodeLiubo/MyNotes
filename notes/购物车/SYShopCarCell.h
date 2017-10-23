//
//  SYShopCarCell.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShopCarGoodsCellModel;


@interface SYShopCarCell : UITableViewCell

/** 商品 */
@property (nonatomic,strong) ShopCarGoodsCellModel *model;

@end
