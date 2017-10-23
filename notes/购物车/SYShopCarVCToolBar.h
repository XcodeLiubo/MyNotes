//
//  SYShopCarVCToolBar.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYShopCarVCToolBar : UIView
/** 当前总价格 */
@property (nonatomic,assign) float currentTotlasPrice;

/** 也是当前总价格 但是因为用户没选中, 所以偷偷的记录 */
@property (nonatomic,assign) float statisticsTotlas;

/** 记录这次操作是 点击了全选 来操作的 */
@property (nonatomic,assign,getter=isAllSelected) BOOL allSelected;

/** 当前的模式 */
@property (nonatomic,assign) ShopModeStyle style;

/** 记录当前单元格选中的个数(购物模式下)  当手动一个一个选中 商品的时候 如果所有的都选中了,就将 最下边的全选选中, 反之 只要有一个取消, 全选就取消*/
@property (nonatomic,assign) NSInteger currentSelectedGoodCounts;

/** 和上面的一样 这个是在 编辑模式下记录 */
@property (nonatomic,assign) NSInteger e_currentSelectedGoodCounts;

/** 在商品界面添加商品后 由于清空了数组, 这里要将所有的数据还原 */
- (void)clearAll;
@end
