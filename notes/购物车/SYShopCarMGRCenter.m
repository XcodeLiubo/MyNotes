//
//  SYShopCarMGRCenter.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYShopCarMGRCenter.h"
#import "SYShopCarVCToolBar.h"
#import "SYShopCarCell.h"

@implementation ShopCarGoodsCellModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if([key isEqualToString:@"id"]){
        self.ID = value;
    }
}


#warning --- 这个代码不要删除
- (void)setE_selected:(BOOL)e_selected{
    
    _e_selected = e_selected;
    if(!e_selected){
        
//        ShopCarMGR->_selectGoodArray[self.indexInArray] = 0;
//
//        [ShopCarMGR->_tempDic removeObjectForKey:self];
    }
    
    
    
    
    
//    else
//        ShopCarMGR->_selectGoodArray[self.indexInArray] = 0;
    
}

- (void)setPic:(NSString *)pic{
    _pic = [NSString stringWithFormat:@"%@%@",img_url_prefix,pic];
}

- (void)setID:(NSString *)ID{
    _ID = [NSString stringWithFormat:@"%@",ID];
}

- (void)setNum:(NSString *)num{
    if(_num == nil){
        self.origin = [num integerValue];
    }
    _num = [NSString stringWithFormat:@"%@", num];
    
}

- (void)setPrice:(NSString *)price{
    _price = [NSString stringWithFormat:@"¥ %@",price];
}

- (void)setMemberId:(NSString *)memberId{
    _memberId = [NSString stringWithFormat:@"%@",memberId];
}

- (void)setWeight:(NSString *)weight{
    _weight = [NSString stringWithFormat:@"%@",weight];
}

- (void)setGoodsSpecId:(NSString *)goodsSpecId{
    _goodsSpecId = [NSString stringWithFormat:@"%@",goodsSpecId];
}

+ (instancetype)modleWithDic:(NSDictionary *)dic{
    ShopCarGoodsCellModel *model = ShopCarGoodsCellModel.alloc.init;
    [model setValuesForKeysWithDictionary:dic];
    //当前肯定是购物模式  所以 当前的交互一定是打开的
    /**
         打开交互 主要目的是 如果用户 刚进来 就点击减号 就会刷新表格, 但是当前interfaceBtn 默认是0的  刷新表格到cell的时候, 会去改变cell的 减号的交互状态 所以这里要默认为1 保证在购物模式下是能交互的  后面点击切换了 编辑购物 就会自动赋值 去改变交互的状态
     */
    model.interfaceBtn = 1;
    return model;
}



#pragma mark --- 重载系统的方法
/** 这里返回 自身 不能 返回新对象 */
- (id)copyWithZone:(NSZone *)zone{
    return self;
    
}


- (BOOL)isEqual:(id)object{
    if(self != object)return NO;
    return YES;
}

- (NSUInteger)hash {
    return [super hash];
}

@end









static SYShopCarMGRCenter *_mgr;
@implementation SYShopCarMGRCenter

+ (instancetype)mgr{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[self alloc] init];
        _mgr.modeStyle = kShopModeStyleShopping;
        _mgr->_tempDic = @{}.mutableCopy;
    });
    
    return _mgr;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [super allocWithZone:zone];
    });
    return _mgr;
}



- (instancetype)init{
    self = [super init];
    if (self) {
        if(_shopsArray) return self;
        _shopsArray = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}



#pragma mark --- 更改模式
- (void)setModeStyle:(ShopModeStyle)modeStyle{
    _modeStyle = modeStyle;
    self.globalToolBar.style = modeStyle;
    
    //只要切换到编辑模式  就全部设置为不选中标记
    [_shopsArray enumerateObjectsUsingBlock:^(ShopCarGoodsCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(modeStyle == kShopModeStyleEdit){
            obj.e_selected = NO;
            if([obj.num integerValue] == 1)
                obj.interfaceBtn = 0;
            else
                obj.interfaceBtn = 1;
            
        }else obj.interfaceBtn = 1;
    }];
    
    [self.globalTable reloadData];
}
@end
