//
//  SYGoodsCell.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark --- 具体的商品
@interface GoodsModel : NSObject
/** 名称 */
@property (nonatomic,copy)NSString *goodsName;

/** 主键 */
@property (nonatomic,copy)NSString *ID;

/** 图片 */
@property (nonatomic,copy)NSString *pic;

/** 规格 */
@property (nonatomic,copy)NSString *name;

/** 数量 */
@property (nonatomic,copy)NSString *num;

/** 重量 */
@property (nonatomic,copy)NSString *weight;

/** 价格 */
@property (nonatomic,copy) NSString *price;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
@end


@interface SYGoodsCell : UICollectionViewCell
/** 模型 */
@property (nonatomic,strong) GoodsModel *model;
@end
