//
//  SYGoodsCell.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYGoodsCell.h"
#import <Masonry/Masonry.h>
#import "SYShopCarVC.h"
#import "SYShopCarVCToolBar.h"


@implementation GoodsModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if([key isEqualToString:@"id"]) self.ID = value;
}

- (void)setPic:(NSString *)pic{
    _pic = [NSString stringWithFormat:@"%@%@",img_url_prefix,pic];
}

- (void)setID:(NSString *)ID{
    _ID = [NSString stringWithFormat:@"%@",ID];
}

- (void)setNum:(NSString *)num{
    _num = [NSString stringWithFormat:@"%@",num];
}

- (void)setPrice:(NSString *)price{
    _price = [NSString stringWithFormat:@"%@",price];
}

- (void)setWeight:(NSString *)weight{
    _weight = [NSString stringWithFormat:@"%@",weight];
}

+ (instancetype)modelWithDic:(NSDictionary *)dic{
    GoodsModel *model = [[self alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}
@end








@interface SYGoodsCell()
/** back view */
@property (nonatomic,strong) UIView *backView;

/** 商品图片 */
@property (nonatomic,strong) UIImageView *imgV;

/** 商品介绍 */
@property (nonatomic,strong) UILabel *descriptionLab;

/** 价格 */
@property (nonatomic,strong) UILabel *priceLab;

/** 购物车 */
@property (nonatomic,strong) UIImageView *shopCarImgV;

@end

@implementation SYGoodsCell
- (instancetype)initWithFrame:(CGRect)frame{
    return (self = [super initWithFrame:frame],(!self ? :[self setUPUI]),self);
}

- (void)setUPUI{
    UIView *backView = [[UIView alloc] init];
    backView.frame = CGRectMake(0, 0, self.w, self.w);
    [backView.layer addSublayer:[self shadowLayer]];
    [self.contentView addSubview:backView];
    _backView = backView;
    
    _imgV = [[UIImageView alloc] init];
    [backView addSubview:_imgV];
    
    
    
    _descriptionLab = [[UILabel alloc] init];
    _descriptionLab.font = [UIFont systemFontOfSize:15];
    _descriptionLab.text = @"fjlafdsafasdfas";
    _descriptionLab.numberOfLines = 0;
    _descriptionLab.textColor = COLOR(000000);
    [self.contentView addSubview:_descriptionLab];
    
    //¥
    _priceLab = [[UILabel alloc] init];
    _priceLab.font = [UIFont systemFontOfSize:15];
    _priceLab.textColor = COLOR(ff0000);
    _priceLab.text = @"¥ 50.00";
    [self.contentView addSubview:_priceLab];
    
    
    _shopCarImgV = [[UIImageView alloc] init];
    _shopCarImgV.userInteractionEnabled = YES;
    _shopCarImgV.image = IMAGE(cart1);
    _shopCarImgV.layer.cornerRadius = 12;
    _shopCarImgV.layer.masksToBounds = YES;
    [self.contentView addSubview:_shopCarImgV];
    
    
    ///给购物车添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chosseTheGoods:)];
    [_shopCarImgV addGestureRecognizer:tap];
    
    
    [self masonry];
}



#pragma mark --- 布局
- (void)masonry{
    CGFloat begin_x = 30;
    
    [_imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(begin_x));
        make.right.equalTo(@(-begin_x));
        make.top.equalTo(@(begin_x));
        make.bottom.equalTo(@(-begin_x + 10));
    }];
    
    
    [_descriptionLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.width.lessThanOrEqualTo(@(self.w));
        make.top.equalTo(self.backView.mas_bottom).offset(0);
    }];
    
    
    [_priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_descriptionLab.mas_left);
        make.bottom.equalTo(_shopCarImgV.mas_bottom);
        make.top.equalTo(_descriptionLab.mas_bottom).offset(0);
    }];
    
    [_shopCarImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.top.equalTo(_priceLab.mas_top);
        make.width.equalTo(@(24));
        make.height.equalTo(@(24));
    }];
}


#warning --- 创建边框  后面会改成 Quartz2D
- (CALayer *)shadowLayer{
    CALayer *layer = [CALayer layer];
    layer.shadowRadius = 5;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowColor = COLOR(eaeaea).CGColor;
    layer.borderColor = COLOR(dddddd).CGColor;
    layer.borderWidth = 1;
    layer.position = CGPointMake(self.w * 0.5, self.w * 0.5);
    layer.bounds = CGRectMake(0, 0, self.w, self.w);
    return layer;
}



#pragma mark --- 数据源 填充
- (void)setModel:(GoodsModel *)model{
    _model = model;
    
    [_imgV sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:nil];
    
    _descriptionLab.text = model.goodsName;
    
    _priceLab.text = model.price;
    
}



#pragma mark -- 购物车点击
- (void)chosseTheGoods:(UITapGestureRecognizer *)tap{
    [SVProgressHUD showWithStatus:@"正在加入购物车..."];
#warning 这里的数量写的是死的 model里面有个num
    [[SYRequest shareRquest] syRequestWithURL:r_goods_add Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,@"goodsSpecId",_model.ID,@"num",@1,nil) sucessBlock:^(id obj) {
        [SVProgressHUD dismiss];
        if (r_obj()) {
            [ShopCarMGR.globalToolBar clearAll];
            [[SYShopCarVC shareInstance] requesGoodsList];
        }else{
            XYLog(@"%@",r_obj_msg());
        }
    } failBlock:^(id obj) {
        [SVProgressHUD dismiss];
    }];
    
}

@end
