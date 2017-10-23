//
//  SYGoodsCategoryCell.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYGoodsSubCategoryModel;





@interface GoodsCategoryModel : NSObject

+ (instancetype)modelWithDic:(NSDictionary *)dic;
/** 名称 */
@property (nonatomic,copy) NSString *name;

/** 编码 */
@property (nonatomic,copy) NSString *code;

/** 子级标题 */
@property (nonatomic,strong) NSArray<SYGoodsSubCategoryModel *> *children;


//附加
/** 标题的宽度 */
@property (nonatomic,assign) CGFloat title_W;

/** 当前model对应在导航的 下标 */
@property (nonatomic,assign) NSInteger index;

/** 是否选中 */
@property (nonatomic,assign,getter=isSelected) BOOL selected;
@end







typedef void(^TitleClickBlock)(NSInteger index);

@interface SYGoodsCategoryCell : UICollectionViewCell

/** 点击title时的回调 */
@property (nonatomic,copy) TitleClickBlock titleClick;

/** 模型 */
@property (nonatomic,strong) GoodsCategoryModel *model;

@end
