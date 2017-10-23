//
//  SYShopCarVCToolBar.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYShopCarVCToolBar.h"

static NSInteger const shareBtnTag          = 100;
static NSInteger const attentionBtnTag      = 101;
static NSInteger const deleteBtnTag         = 102;



@interface SYShopCarVCToolBar()

/** choose 全选 */
@property (nonatomic,strong) UIButton *chooseAllBtn;

/** 总计 */
@property (nonatomic,strong) UILabel *totalsLab;

/** 快递费用 */
@property (nonatomic,strong) UILabel *emsLab;

/** 提交订单 */
@property (nonatomic,strong) UIButton *sureBtn;



/** 分享 */
@property (nonatomic,strong) UIButton *shareBtn;

/** 关注 */
@property (nonatomic,strong) UIButton *attentionBtn;

/** 删除 */
@property (nonatomic,strong) UIButton *deleteBtn;



///附加
/** 记录全选按钮 在 购物模式 下的状态 以便在编辑模式后 回到购物模式后 显示为原来的状态 */
@property (nonatomic,assign,getter=isSelectedStateInShopMode) BOOL selectedStateInShopMode;
@end


@implementation SYShopCarVCToolBar
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUPUI];
    }return self;
}



#pragma mark --- 重置数据
- (void)clearAll{
    
    free(ShopCarMGR->_selectGoodArray);
    [ShopCarMGR->_tempDic removeAllObjects];
//    for (NSInteger i = 0; i< shopMgrArray.count * 2; i++) {
//        //这里要释放掉
//        ShopCarMGR->_selectGoodArray[i] = -1;  //标记所有的商品 在购物模式或者编辑模式 为删除的状态
//        [ShopCarMGR->_tempDic removeAllObjects];
//    }
    [shopMgrArray removeAllObjects];
    _currentTotlasPrice = _statisticsTotlas = _allSelected = 0;
    ShopCarMGR.modeStyle = kShopModeStyleShopping;
    _chooseAllBtn.selected = NO;
    self.currentTotlasPrice = 0;
    _currentSelectedGoodCounts = _e_currentSelectedGoodCounts = 0;
    
}



#pragma mark --- UI
- (void)setUPUI{
    
#define 购物模式布局
    _chooseAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chooseAllBtn setImage:IMAGE(shop-car-chossebtn) forState:UIControlStateNormal];
    [_chooseAllBtn setImage:IMAGE(exchangeSelctRight) forState:UIControlStateSelected];
    
    [_chooseAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [_chooseAllBtn setTitle:@"全选" forState:UIControlStateHighlighted];
    
    [_chooseAllBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    _chooseAllBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _chooseAllBtn.backgroundColor = COLOR(ffffff);
    
    [_chooseAllBtn addTarget:self action:@selector(allClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:_chooseAllBtn];
    
    
    
    _totalsLab = [[UILabel alloc]init];
    _totalsLab.backgroundColor = COLOR(ffffff);
    _totalsLab.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_totalsLab];
    
    
    _emsLab = [[UILabel alloc] init];
    _emsLab.backgroundColor = COLOR(ffffff);
    _emsLab.font = [UIFont systemFontOfSize:13];
    [self addSubview:_emsLab];
    
    
    _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sureBtn setTitleColor:COLOR(ffffff) forState:UIControlStateNormal];
    [_sureBtn setTitle:@"提交订单" forState:UIControlStateHighlighted];
    [_sureBtn setTitle:@"提交订单" forState:UIControlStateNormal];
    _sureBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    _sureBtn.backgroundColor = COLOR(ff0000);
    [_sureBtn addTarget:self action:@selector(suerClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sureBtn];
    
    
    
#define 编辑模式布局
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _shareBtn.tag = shareBtnTag;
    [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [_shareBtn setTitle:@"分享" forState:UIControlStateHighlighted];
    [_shareBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    [_shareBtn setTitleColor:COLOR(ff0000) forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(editModelClick:) forControlEvents:UIControlEventTouchUpInside];
    _shareBtn.hidden = YES;
    [self addSubview:_shareBtn];
    
    
    
    _attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _attentionBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _attentionBtn.tag = attentionBtnTag;
    [_attentionBtn setTitle:@"更新" forState:UIControlStateNormal];
    [_attentionBtn setTitle:@"更新" forState:UIControlStateHighlighted];
    [_attentionBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    [_attentionBtn setTitleColor:COLOR(ff0000) forState:UIControlStateHighlighted];
    [_attentionBtn addTarget:self action:@selector(editModelClick:) forControlEvents:UIControlEventTouchUpInside];
    _attentionBtn.hidden = YES;
    [self addSubview:_attentionBtn];
    
    
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    _deleteBtn.backgroundColor = COLOR(ff0000);
    _deleteBtn.tag = deleteBtnTag;
    [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [_deleteBtn setTitle:@"删除" forState:UIControlStateHighlighted];
    [_deleteBtn setTitleColor:COLOR(ffffff) forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(editModelClick:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.hidden = YES;
    [self addSubview:_deleteBtn];
    
}



#pragma mark --- 编辑模式下各个按钮的点击
- (void)editModelClick:(UIButton *)btn{
    switch (btn.tag) {
        case shareBtnTag:{
            [SVProgressHUD setForegroundColor:COLOR(000000)];
            [SVProgressHUD showInfoWithStatus:@"分享 此功能没开发"];
        }break;
            
        case attentionBtnTag:{
            [self updateData];
        }break;
            
        case deleteBtnTag:{
            [self handDelete];
        }break;
            
        default:
            break;
    }
}



#pragma mark -- 更新
- (void)updateData{
    if(self.e_currentSelectedGoodCounts == 0){
        [SVProgressHUD showWithStatus:@"你还没选中商品"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    
    [shopMgrArray enumerateObjectsUsingBlock:^(ShopCarGoodsCellModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.num integerValue] != model.origin){
            [[SYRequest shareRquest] syRequestWithURL:r_goods_car_update Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,@"goodsSpecId",model.goodsSpecId,@"num",model.num,nil) sucessBlock:^(id obj) {
                if(r_obj()){
                    
                    //重载所有的数据 先清空
                    [self clearAll];
                    
                    //再请求新的数据
                    PostNoti(@"更新数据成功,重新请求数据刷新", nil);
                }else{
                    XYLog(@"%@",r_obj_msg());
                }
            } failBlock:^(id obj) {
                XYLog(@"%@",obj);
            }];
        }
    }];
}



#pragma mark --- 处理删除
- (void)handDelete{
    if(self.e_currentSelectedGoodCounts == 0){
        [SVProgressHUD showWithStatus:@"你还没选中商品"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    
    //如果是全选状态 这里表示要清空
    if(_chooseAllBtn.isSelected){
        [[SYRequest shareRquest] syRequestWithURL:r_goods_car_clear_goods Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,nil) sucessBlock:^(id obj) {
            if (r_obj()) {
                [self clearAll];
                [ShopCarMGR.globalTable reloadData];
            }else{
                NSLog(@"%@",r_obj_msg());
            }
        } failBlock:^(id obj) {
            NSLog(@"%@",obj);
        }];
        return;
    }
    
    
#warning 找到当前那个商品选中了 删掉 这段代码不要删掉
//    for (NSInteger i = 0; i< shopMgrArray.count * 2; i++) {
//        if(ShopCarMGR->_selectGoodArray[i] == 1){ //表示要删除的商品
//            ShopCarGoodsCellModel *model = shopMgrArray[i];
//
//
//
//            [[SYRequest shareRquest] syRequestWithURL:r_goods_car_del Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,@"goodsSpecId",model.goodsSpecId,nil) sucessBlock:^(id obj) {
//                if(r_obj()){
//
//                }else{
//                    XYLog(@"%@",r_obj_msg());
//                }
//            } failBlock:^(id obj) {
//                XYLog(@"%@",obj);
//            }];
//
//
//        }
//    }
    
    
    //遍历数组 删除部分 商品
    [shopMgrArray enumerateObjectsUsingBlock:^(ShopCarGoodsCellModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if(model.e_selected){
            [[SYRequest shareRquest] syRequestWithURL:r_goods_car_del Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,@"goodsSpecId",model.goodsSpecId,nil) sucessBlock:^(id obj) {
                if(r_obj()){
                     
                    [shopMgrArray removeObject:model];
                    
                    //将当前的价格 这里减去的是 这个商品的总和  在加减哪里 只是一个一个的减 这里不同
                    ShopCarMGR.globalToolBar.currentTotlasPrice -= [[model.price substringFromIndex:2] floatValue] * [model.num integerValue];
                    if(ShopCarMGR.globalToolBar.currentTotlasPrice <= 0){
                        ShopCarMGR.globalToolBar.currentTotlasPrice = 0;
                    }
                    
                    //要减去1 同时要判断来到编辑模式的时候, 这个模型有没有在购物模式下有么有被选中  这样回到购物模式数据才一致
                    if(model.isSeleted)
                        ShopCarMGR.globalToolBar.currentSelectedGoodCounts--;
                    
                    //标记这个商品 的下标状态  这里表示 在购物模式下(实际上也只能在这个模式下) 被删除的状态
                    //ShopCarMGR->_selectGoodArray[model.indexInArray] = -1;
                    //[ShopCarMGR->_tempDic removeObjectForKey:model];
                    

                    [ShopCarMGR.globalTable reloadData];
                 
                }else{
                    XYLog(@"%@",r_obj_msg());
                }
            } failBlock:^(id obj) {
                XYLog(@"%@",obj);
            }];
            
        }
    }];
}



#pragma mark --- 界面上展示的总价格 根据当前界面上选中的商品的个数 根据加减按钮和和全选按钮的操作时刻在变化
- (void)setCurrentTotlasPrice:(float)currentTotlasPrice{
    _currentTotlasPrice = currentTotlasPrice;
    [self updatePrice];
}



#pragma mark --- 总价格的显示
- (void)updatePrice{
    NSString *str = [NSString stringWithFormat:@"¥ %.2f",_currentTotlasPrice];
    NSAttributedString *att =[[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName:COLOR(ff0000),NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"总计: " attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}];
    NSAttributedString *str2 = [[NSAttributedString alloc] initWithString:@"(含快递运费)" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]}];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] init];
    [str3 appendAttributedString:str1];
    [str3 appendAttributedString:att];
    [str3 appendAttributedString:str2];
    
    _totalsLab.attributedText = str3;
}



#pragma mark --- 切换模式
- (void)setStyle:(ShopModeStyle)style{
    _style = style;
    if(style == kShopModeStyleEdit){
        _totalsLab.hidden = _emsLab.hidden = _sureBtn.hidden = YES;
        _shareBtn.hidden = _attentionBtn.hidden = _deleteBtn.hidden = NO;
        _e_currentSelectedGoodCounts = 0;
        _selectedStateInShopMode = _chooseAllBtn.isSelected;
        _chooseAllBtn.selected = NO;
        
    }else{
        _totalsLab.hidden = _emsLab.hidden = _sureBtn.hidden = NO;
        _shareBtn.hidden = _attentionBtn.hidden = _deleteBtn.hidden = YES;
        _chooseAllBtn.selected = _selectedStateInShopMode;
        if(self.currentSelectedGoodCounts == shopMgrArray.count){
            NSLog(@"%zd   %zd",self.currentSelectedGoodCounts,shopMgrArray.count);
            _chooseAllBtn.selected = YES;
        }
    }
}



#pragma mark --- 根据当前在购物模式下选中的商品的个数来决定是不是要全选
- (void)setCurrentSelectedGoodCounts:(NSInteger)currentSelectedGoodCounts{
    _currentSelectedGoodCounts = currentSelectedGoodCounts;
    
    //这种情况是 编辑模式下 删除要将 购物模式下的统计做减1操作   但因为是在编辑模式下 不能立即更新全选按钮的状态 回到购物模式下要更新
    if(self.style == kShopModeStyleEdit)return;
    [self changeState:currentSelectedGoodCounts];
    
}



#pragma mark --- 根据当前在编辑模式下 选中的商品个数 来决定要不要全选
- (void)setE_currentSelectedGoodCounts:(NSInteger)e_currentSelectedGoodCounts{
    _e_currentSelectedGoodCounts = e_currentSelectedGoodCounts;
    [self changeState:e_currentSelectedGoodCounts];
}



#pragma mark --- 改变全选按钮的状态
- (void)changeState:(NSInteger)counts{
    if(counts == shopMgrArray.count){
        //设置全选按钮为选中状态
        _chooseAllBtn.selected = YES;
    }else if(counts == shopMgrArray.count - 1){
        //保证 只做一次 如果直接else 那么 只要不等于数组的长度 就会调用一次 所有没必要 每次都调用 加上这个if 就只用执行一次
        _chooseAllBtn.selected = NO;
    }
}




#pragma mark --- 全选按钮的点击
- (void)allClick{
    
    _chooseAllBtn.selected = !_chooseAllBtn.isSelected;
    BOOL isSelected = _chooseAllBtn.isSelected;
    
    NSInteger count = shopMgrArray.count;
    if(_style == kShopModeStyleEdit)
        _e_currentSelectedGoodCounts = isSelected ? count :0;
    else
        _currentSelectedGoodCounts = isSelected ? count :0;
    
    
    _allSelected = YES;
    [shopMgrArray enumerateObjectsUsingBlock:^(ShopCarGoodsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //编辑模式
        if(_style == kShopModeStyleEdit){
            obj.e_selected = NO;
            
            if(isSelected) obj.e_selected = YES;
            
            if(idx == count - 1) [ShopCarMGR.globalTable reloadData];
            
            return ;
        }
        
        
        
        //购物模式
        obj.selected = NO;
        
        if(isSelected) obj.selected = YES;
        
        if(idx == count - 1){
            [ShopCarMGR.globalTable reloadData];
        }
    }];
}



#pragma mark --- 提交订单
- (void)suerClick{
    XYLog(@"提交");
}


#pragma mark --- 重新布局
- (void)layoutSubviews{
    [super layoutSubviews];
    _chooseAllBtn.x = 0;
    _chooseAllBtn.y = 0;
    _chooseAllBtn.w = self.w / 3 - 5;
    _chooseAllBtn.h = self.h;
    
    
    _totalsLab.w = self.w /3 + 25;
    _totalsLab.h = 24;
    _totalsLab.x = _chooseAllBtn.m_x;
    _totalsLab.y = 0;
    
    
    _emsLab.x = _totalsLab.x;
    _emsLab.y = _totalsLab.m_y;
    _emsLab.w = _totalsLab.w;
    _emsLab.h = self.h - _totalsLab.h;
    
    _sureBtn.x = _totalsLab.m_x;
    _sureBtn.y = 0;
    _sureBtn.h = _chooseAllBtn.h;
    _sureBtn.w = self.w - _totalsLab.m_x;
    
    
    
    _shareBtn.x = _chooseAllBtn.m_x;
    _shareBtn.y = _chooseAllBtn.y;
    _shareBtn.w = (self.w - _chooseAllBtn.m_x) / 3;
    _shareBtn.h = _chooseAllBtn.h;
    
    
    _attentionBtn.frame = _shareBtn.frame;
    _attentionBtn.x = _shareBtn.m_x;
    
    
    _deleteBtn.frame = _shareBtn.frame;
    _deleteBtn.x = _attentionBtn.m_x;
}
@end
