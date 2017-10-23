//
//  SYShopCarMGRCenter.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ShopModeStyle) {
    kShopModeStyleShopping  = 100,              //购物模式
    kShopModeStyleEdit      = 1000              //编辑模式
};



@class SYShopCarVCToolBar;


@interface ShopCarGoodsCellModel : NSObject<NSCopying>
/** 主键 */
@property (nonatomic,copy) NSString *ID;

/** 商品规格主键 */
@property (nonatomic,copy) NSString *goodsSpecId;

/** 数量 */
@property (nonatomic,copy) NSString *num;

/** 图片 */
@property (nonatomic,copy) NSString *pic;

/** 商品名 */
@property (nonatomic,copy) NSString *goodsName;

/** 商品规格 */
@property (nonatomic,copy) NSString *goodsSpecName;

/** 价格  */
@property (nonatomic,copy) NSString *price;

/** 重量 */
@property (nonatomic,copy) NSString *weight;

/** 会员 */
@property (nonatomic,copy) NSString *memberId;

+ (instancetype)modleWithDic:(NSDictionary *)dic;




///附加
/** 是否选中 标记每件商品的选中状态 */
@property (nonatomic,assign,getter=isSeleted) BOOL selected;

/** 是否选中 标记是否减到零 */
@property (nonatomic,assign,getter=isZero) BOOL zero;

/** 是不是第一次 用来判断 */
@property (nonatomic,assign,getter=isFirst) BOOL first;


/** 记录 手动点击商品cell 取消选中时, 记录当前这个商品的总价格 */
@property (nonatomic,assign) float cancelClickTotals;

/** 编辑状态是否选中 */
@property (nonatomic,assign,getter=isEditSelect) BOOL e_selected;

/** 在数组中的下标 */
@property (nonatomic,assign) NSInteger indexInArray;

/** 标记 减号的交互状态 0: 不能交互  1: 能交互 */
@property (nonatomic,assign) NSInteger interfaceBtn;

/** 记录最开始创建 model的时候 有少个, 主要是更新时拿这个和当前的num判断 */
@property (nonatomic,assign) NSInteger origin;
@end


@interface SYShopCarMGRCenter : NSObject
{
    @public
    /** 记录选中的 商品的下标 是2倍数组的宽度,
         为的是 记录购物模式和编辑模式
             偶数位是购物模式, 奇数位是编辑模式,
             记录状态  0:表示商品存在 但是没选中    1: 表示商品存在被选中了    -1:表示商品不存在了,被点击减号删除了(只是在购物模式下会出现
         虽然模型中记录了选中是否,但是遍历数组还要进入模型判断, 没有直接遍历标记快, 虽然牺牲了空间*/
    int *_selectGoodArray OVERDUE_VAR("过期了, 改成了oc的数组, 因为添加或删除商品 要同步数组,比较麻烦");
    
    /**   上面过期的作用一样  key:index(偶数代表购物模式, 奇数代表编辑模式)  value:model  因为删除或者增加商品要重新同步下标, 所以用oc的比较方便*/
    NSMutableDictionary<ShopCarGoodsCellModel*, NSArray *> *_tempDic;
}

+ (instancetype)mgr;

/** 在购物车里的商品数组 里面存放的是商品  */
@property (nonatomic,strong) NSMutableArray<ShopCarGoodsCellModel *> *shopsArray;

/** 购物车界面下的全选 是全局的放到这里 直接拿 比较方便 */
@property (nonatomic,weak) SYShopCarVCToolBar *globalToolBar;

/** 购物车里的表格 */
@property (nonatomic,weak) UITableView *globalTable;


/** 模式 */
@property (nonatomic,assign) ShopModeStyle modeStyle;



@end
