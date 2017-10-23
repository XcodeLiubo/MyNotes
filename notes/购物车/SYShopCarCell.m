//
//  SYShopCarCell.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYShopCarCell.h"
#import <Masonry/Masonry.h>
#import "SYShopCarVCToolBar.h"



@interface MYStepper : UIView
{
    UIView *_lineView1;
    UIView *_lineView2;
}

/** 减 按钮 */
@property (nonatomic,strong) UIButton *subBtn;

/** 显示 */
@property (nonatomic,strong) UILabel *label;

/** 加 按钮 */
@property (nonatomic,strong) UIButton *addBtn;

/** 模型 */
@property (nonatomic,strong) ShopCarGoodsCellModel *model;



///////////////////////////////////////// 附加 ////////////////////////////
/** 当前的价格 */
@property (nonatomic) float price;

/** 总数 */
@property (nonatomic,assign) NSInteger num;

/** 改变btn的交互 */
- (void)changeJianBtnUserface;

@end

@implementation MYStepper

- (instancetype)init{
    self = [super init];
    if (self) {
        [self setUPUI];
    }
    return self;
}



#pragma mark --- UI
- (void)setUPUI{
    _subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_subBtn setTitle:@"-" forState:UIControlStateNormal];
    [_subBtn setTitleColor:COLOR(d6d6d6) forState:UIControlStateSelected];
    [_subBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    [_subBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    _subBtn.layer.borderWidth = 1;
    _subBtn.layer.borderColor = COLOR(d6d6d6).CGColor;
    [self addSubview:_subBtn];
    
    
    _label = [[UILabel alloc] init];
    _label.textColor = COLOR(000000);
    _label.font = [UIFont systemFontOfSize:13];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"1";
    [self addSubview:_label];
    
    
    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addBtn setTitle:@"+" forState:UIControlStateNormal];
    [_addBtn setTitleColor:COLOR(d6d6d6) forState:UIControlStateSelected];
    [_addBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    _addBtn.layer.borderWidth = 1;
    _addBtn.layer.borderColor = COLOR(d6d6d6).CGColor;
    [_addBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_addBtn];
    
    
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = COLOR(d6d6d6);
    [self addSubview:lineView1];
    _lineView1 = lineView1;
    
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = COLOR(d6d6d6);
    [self addSubview:lineView2];
    _lineView2 = lineView2;
    
    return;
}


#pragma mark --- 改变减号按钮的交互
- (void)changeJianBtnUserface{
    self.subBtn.userInteractionEnabled = _model.interfaceBtn;
}



#pragma mark --- 重载 模型赋值的操作
- (void)setModel:(ShopCarGoodsCellModel *)model{
    _model = model;
    NSString *str = [model.price substringFromIndex:2];
    _label.text = model.num;
    
    _price = [str floatValue];
    _num = [model.num integerValue];
    
    model.first = YES;
    
    ///偷偷的统计
    ShopCarMGR.globalToolBar.statisticsTotlas += _price * _num;
    
    
    ///如果是选中状态 就显示总数据(最下边的toolbar)
    if(model.isSeleted)
        ShopCarMGR.globalToolBar.currentTotlasPrice += _price * _num;
    
}



#pragma mark --- 提醒删除
- (void)remindDelete{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除该商品" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelBtn = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    
    UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[SYRequest shareRquest] syRequestWithURL:r_goods_car_del Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,@"goodsSpecId",_model.goodsSpecId,nil) sucessBlock:^(id obj) {
            if(r_obj()){
                [shopMgrArray removeObject:_model];
                //将当前的价格 减去
                ShopCarMGR.globalToolBar.currentTotlasPrice -= _price;
                if(ShopCarMGR.globalToolBar.currentTotlasPrice <= 0){
                    ShopCarMGR.globalToolBar.currentTotlasPrice = 0;
                }
                
                //判断要不要全选 商品模式下
                if(ShopCarMGR.modeStyle == kShopModeStyleShopping){
                    ShopCarMGR.globalToolBar.currentSelectedGoodCounts--;
                }
                
                //标记这个商品 的下标状态  这里表示 在购物模式下(实际上也只能在这个模式下) 被删除的状态
                ShopCarMGR->_selectGoodArray[_model.indexInArray] = -1;
                [ShopCarMGR->_tempDic removeObjectForKey:_model];
                
#warning 重新整理下标  数据个数不一致了  而且再回去重新添加商品后也要 这个功能还是用数组遍历实现了 但是我的想法在改变状态的过程中 添加目的商品 最后直接拿要处理的 商品数组 去遍历请求 不用所有的都遍历然后去判断
                
                
                [ShopCarMGR.globalTable reloadData];
            }else{
                XYLog(@"%@",r_obj_msg());
            }
        } failBlock:^(id obj) {
            XYLog(@"%@",obj);
        }];
    }];
    
    [alertVC addAction:actionSure];
    [alertVC addAction:cancelBtn];
    PostNoti(@"弹出删除商品", alertVC);
}




#pragma mark --- 点击加减按钮的 逻辑 点击加减只是为了更新按钮的选中状态是否 没有别的逻辑 但是要动态改变 toolbar中对应的模型的值保证及时更新在对应模式下tollbar的显示
static int _flag;
- (void)click:(UIButton *)btn{
    
    if(_num == 1 && btn == _subBtn){
        
        //编辑模式 不提示删除 再切换到购物模式的时候,将交互打开
        if(ShopCarMGR.modeStyle == kShopModeStyleEdit){
            _model.interfaceBtn = 0;
            [ShopCarMGR.globalTable reloadData];
            return;
        }
        
        
        
        _model.interfaceBtn = 1;
        
        [ShopCarMGR.globalTable reloadData];
        
        //提醒 删除
        [self remindDelete];
        
        return;
    }
    
    
    
    _flag = -1;
    if(btn == _addBtn) _flag = 1;
    
    _num += _flag;
    
    
    _model.num = [NSString stringWithFormat:@"%zd",_num];
    _label.text = _model.num;
    
    
    ///偷偷的统计 点击了就统计
    ShopCarMGR.globalToolBar.statisticsTotlas += (_flag * _price);
    
    
    ///如果是选中状态 就实时更新总数据(最下边的toolbar)
    if(_model.isSeleted)
        ShopCarMGR.globalToolBar.currentTotlasPrice += (_flag * _price);
    
    
    if(!_model.isSeleted){      _model.selected = YES; //强制选中
        
        
        /**
             如果是首次进入到购物车 然后商品没选中的话, 点击加号将商品选中后 计算出当前商品总价 要显示到界面上 只做一次
         */
        if(_model.isFirst){
            ShopCarMGR.globalToolBar.currentTotlasPrice += _price * _num;
            _model.first = NO;
            
            /**
                 第一次进来由于没选中 点击加\减 会标记按钮的选中, 在下一次人runloop回调中 会根据这里标记 设置按钮 为选中状态(商品的 setmodel方法里) 所以这里要统计改好选中的标记(就是管理中心里的统计购物模式下多少个按钮选中的属性)
             */
            ShopCarMGR.globalToolBar.currentSelectedGoodCounts++;
            
            
            /**
                 标记当前按钮选中  这里的标记是为了 最后提交部分商品下单  或者删除部分商品的 遍历 不要删除
             */
          //  ShopCarMGR->_selectGoodArray[_model.indexInArray] = 1;
          //  [ShopCarMGR->_tempDic setObject:@[@(1),@(_model.e_selected)] forKey:_model];
            
            
            
            
            /**
                 只有在购物模式下 才需要去判断 cell中btn的选中, 编辑状态下不需要更新按钮的显示状态
             */
            if(ShopCarMGR.modeStyle == kShopModeStyleShopping)
                [ShopCarMGR.globalTable reloadData];
            return;
        }
        
        /**
             如果当前商品没选中,  点击加减号,那么强制选中后,要到这里来 统计购物模式下选中的个数
         */
        ShopCarMGR.globalToolBar.currentSelectedGoodCounts++;
        
        
        /**
             如果商品没选中 那么点击加减 ,强制选中 到这里来将这一次要计入的价格(正负单价)  加上 上一次取消 手动取消选中时  记录的差价(在下边if中)
         */
        ShopCarMGR.globalToolBar.currentTotlasPrice += _flag * _price;
        
        if(_model.cancelClickTotals > 0){ //加上 上次手动取消时的差价
            
            ShopCarMGR.globalToolBar.currentTotlasPrice += _model.cancelClickTotals;
            _model.cancelClickTotals = -1;
        }
        
        if(ShopCarMGR.modeStyle == kShopModeStyleShopping)
            [ShopCarMGR.globalTable reloadData];
    }
}



#pragma mark --- 重载布局
- (void)layoutSubviews{
    [super layoutSubviews];
    
    _subBtn.x = 0;
    _subBtn.y = 0;
    _subBtn.w = 21;
    _subBtn.h = self.h;
    
    
    _lineView1.x = _subBtn.m_x;
    _lineView1.y = _subBtn.y;
    _lineView1.w = self.w  - _subBtn.w * 2;
    _lineView1.h = 1;
    
    
    
    _label.x = _lineView1.x;
    _label.y = _lineView1.m_y;
    _label.w = _lineView1.w;
    _label.h = self.h - 2 * _lineView1.h;
    
    
    
    _lineView2.x = _label.x;
    _lineView2.y = _label.m_y;
    _lineView2.w = _label.w;
    _lineView2.h = _lineView1.h;
    
    
    
    _addBtn.x = _lineView1.m_x;
    _addBtn.y = _subBtn.y;
    _addBtn.w = _subBtn.w;
    _addBtn.h = _subBtn.h;
}
@end















@interface SYShopCarCell()
/** 打钩按钮 */
@property (nonatomic,strong) UIButton *chosseBtn;

/** 商品的图片 */
@property (nonatomic,strong) UIImageView *imgView;

/** 商品的介绍 */
@property (nonatomic,strong) UILabel *desLab;

/** 价格 */
@property (nonatomic,strong) UILabel *priceLab;

/** 规格 */
@property (nonatomic,strong) UILabel *goodsSizeLab;

/** 加减 */
@property (nonatomic,strong) MYStepper *myStepper;

@end


@implementation SYShopCarCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUPUI];
    }
    return self;
}



#pragma mark --- UI
- (void)setUPUI{
    _chosseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_chosseBtn setImage:IMAGE(shop-car-chossebtn) forState:UIControlStateNormal];
    [_chosseBtn setImage:IMAGE(exchangeSelctRight) forState:UIControlStateSelected];
    [_chosseBtn addTarget:self action:@selector(chooseClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_chosseBtn];
    
    
    
    UIView *backView = [[UIView alloc] init];
    [backView.layer addSublayer:[self shadowLayerWith:168/2]];
    [self.contentView addSubview:backView];
    
    
    _imgView = UIImageView.alloc.init;
    [backView addSubview:_imgView];
    
    
    _desLab = [[UILabel alloc] init];
    _desLab.textColor = COLOR(9ea285);
    _desLab.font = [UIFont systemFontOfSize:13];
    _desLab.numberOfLines = 0;
    [self.contentView addSubview:_desLab];
    
    
    _priceLab = [[UILabel alloc] init];
    _priceLab.textColor = COLOR(ff0000);
    _priceLab.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_priceLab];
    
    
    _goodsSizeLab = [[UILabel alloc] init];
    _goodsSizeLab.textColor = COLOR(9ea285);
    _goodsSizeLab.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:_goodsSizeLab];
    
    
    _myStepper = [[MYStepper alloc] init];
    [self.contentView addSubview:_myStepper];
    
    [self masonryWith:backView];
    
}



#pragma mark -- 布局
- (void)masonryWith:(UIView *)backView{
    CGFloat leftMargin = 10;
    
    [_chosseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(leftMargin);
        make.width.equalTo(@19);
        make.height.equalTo(@19);
        make.centerY.offset(0);
    }];
    
    
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_chosseBtn.mas_right).offset(leftMargin);
        make.width.equalTo(@(168/2));
        make.height.equalTo(@(168/2));
        make.top.equalTo(@5);
    }];
    
    
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.right.offset(-15);
        make.top.offset(5);
        make.bottom.offset(-5);
    }];
    
    
    [_desLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backView.mas_right).offset(5);
        make.right.offset(-5);
        make.top.equalTo(backView.mas_top);
        make.bottom.equalTo(_priceLab.mas_top);
    }];
    
    
    
    [_priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_desLab.mas_left);
        make.width.equalTo(@60);
        make.height.equalTo(@30);
    }];
    
    
    [_goodsSizeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_desLab.mas_left);
        make.top.equalTo(_priceLab.mas_bottom);
        make.width.equalTo(@120);
        make.height.equalTo(@21);
        make.bottom.offset(-5);
    }];
    
    
    
    [_myStepper mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_priceLab.mas_bottom);
        make.right.equalTo(_desLab.mas_right);
        make.bottom.equalTo(_goodsSizeLab.mas_bottom).offset(-3);
        make.left.equalTo(_goodsSizeLab.mas_right);
    }];
    return;
}



#pragma mark --- cell的边框
- (CALayer *)shadowLayerWith:(CGFloat)w{
    CALayer *layer = [CALayer layer];
    layer.shadowRadius = 10;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowColor = COLOR(d6d6d6).CGColor;
    layer.borderWidth = 1;
    layer.position = CGPointMake(w * 0.5, w * 0.5);
    layer.bounds = CGRectMake(0, 0, w, w);
    return layer;
}



#pragma mark --- 重载setter frame 方法 分割线实现
- (void)setFrame:(CGRect)frame{
        CGRect rect = frame;
        rect.size.height -= 2;
    
    [super setFrame:rect];
}




#pragma mark --- 模型赋值  业务逻辑比较复杂 主要根据模型里的状态来判断商品左侧的按钮是否要选中
- (void)setModel:(ShopCarGoodsCellModel *)model{
    
    /**
         PS: 调用这个方法 主要是为了更新按钮的选中状态  有这几个来源
         1. 按钮没选中 点击加减的时候 会在model里标记好 来这里更新(这里包括购物模式和编辑模式)
             1.1 还同时要判断更新(根据model的对应的标记调用_myStepper的公开方法)   减号的交互状态
         2. 点击全选的时候 更新了model里的标记状态  会来到这里更新按钮的选中状态
     */
    
    
    if(_model == model){
        BOOL isAllSelected = ShopCarMGR.globalToolBar.isAllSelected;
        ShopModeStyle style = ShopCarMGR.modeStyle;
        
        
        //改变 减号的状态
        [_myStepper changeJianBtnUserface];
        
        
        _chosseBtn.selected = model.isSeleted;
        
        
        //只会在全选点击的时候 编辑模式才会来到这个if
        if(style == kShopModeStyleEdit) {
            _chosseBtn.selected = model.isEditSelect;
            isAllSelected = NO;
            return;
        }
        
        
        if(!isAllSelected)return; //表示从 加减那边过来的  不需要到下边做if判断 这种情况是在编辑模式下 点击加减
        
        
        
        if(model.isSeleted /*|| model.e_selected*/){
            //表示这次的操作是全选  能走到这里的情况还有 就是按钮没选中的时候 点击加或减 代码设置模型的选中状态,然后更新表格来到这里, 只不过这种情况 目的只是根据设置的数据源标记的选中状态来决定按钮要不要选中, 不需要设置价格的显示 所以改成了 上面注释的if(!isAllSelected)
            if(isAllSelected){
            
                
                ShopCarMGR.globalToolBar.currentTotlasPrice = ShopCarMGR.globalToolBar.statisticsTotlas;
                
                //要判断在什么情况下才会赋值位 no  遍历到最后一个时候
                if(model.indexInArray == shopMgrArray.count - 1){
                    ShopCarMGR.globalToolBar.allSelected = NO;
                }
                
            }
         }else{
             //表示这次的操作是全选
             if(isAllSelected){
             label_2:
                 
                 ShopCarMGR.globalToolBar.currentTotlasPrice = 0;
                 
                 //全选取消的时候 统计当前商品的 价格总和 以便手动 再次点击加减 保证将 数据加上去
                 model.cancelClickTotals = [[model.price substringFromIndex:2] floatValue] * [model.num integerValue];
                 
                 
                 //要判断在什么情况下才会赋值位 no  遍历到最后一个时候
                 if(model.indexInArray == shopMgrArray.count - 1){
                     ShopCarMGR.globalToolBar.allSelected = NO;
                 }
             }
        }
        
        return;
    }
    
    
    
    
    
    
    _model = model;
    
    
    _chosseBtn.selected = model.isSeleted;  //这句话可有可无
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:nil];
    
    _desLab.text = model.goodsName;
    
    _priceLab.text = model.price;
    
    _goodsSizeLab.text = model.goodsSpecName;
    
    /**
         这里将model 传给 _myStepper 是为了更新总价格, 因为 只是第一次 或者 数据变化后 才会更新总价,
         这里的 if 可以不写的, 因为函数的开头 已经做 拦截处理了
         因为点击全选的时候, 目的只是处理按钮的选中, 所以在最开头 拦截处理了一下, 如果数据源没有变, 就直接改变当前cell的选中
     */
    _myStepper.model = _model;
}



#pragma mark --- 手动点击取消
- (void)chooseClick:(UIButton *)button{
    ShopCarMGR->_selectGoodArray[_model.indexInArray * 2 + 1] = 0;
    [ShopCarMGR->_tempDic setObject:@[@(_model.selected),@(0)] forKey:_model];
    
    //编辑模式
    if(ShopCarMGR.modeStyle == kShopModeStyleEdit){
        _model.e_selected = !_model.isEditSelect;
        button.selected = _model.isEditSelect;
        
        if(button.isSelected){
            ShopCarMGR.globalToolBar.e_currentSelectedGoodCounts++;
            
            ShopCarMGR->_selectGoodArray[_model.indexInArray * 2 + 1] = 1; //编辑模式下 标记这个商品下标选中
            [ShopCarMGR->_tempDic setObject:@[@(_model.selected),@(1)] forKey:_model];
        }else
            ShopCarMGR.globalToolBar.e_currentSelectedGoodCounts--;
        

        return;
    }
    
    
    _model.selected = !_model.selected;
    button.selected = _model.selected;
    
    
    CGFloat tempPrice = [[_model.price substringFromIndex:2] floatValue];
    NSInteger counts = [_model.num integerValue];
    
    
    //如果是选中状态
    if(_model.isSeleted){
        CGFloat totals = counts * tempPrice;
        
        //计算当前商品的总和
        ShopCarMGR.globalToolBar.currentTotlasPrice += totals;
        
        //统计当前选中的商品
        ShopCarMGR.globalToolBar.currentSelectedGoodCounts++;
        
        //ShopCarMGR->_selectGoodArray[_model.indexInArray * 2] = 1; //购物模式下 记录一下
        //[ShopCarMGR->_tempDic setObject:@[@(1),@(0)] forKey:_model];
        
    }else{
        //将这个商品价格总和 从所有商品价格的总和中减去
        CGFloat totals = ShopCarMGR.globalToolBar.currentTotlasPrice - counts * tempPrice;
        
        /**
             这个减去的数据不能丢弃 因为 手动取消该按钮的选中后, 再次点击 加\减按钮时 , 改按钮会被代码设置为选中, 因为上一次手动取消选中,导致全局的 计数变为0 所以 点击加减按钮后, 数据会出现 错误 即 已经为0的统计 加上或减去了一个商品的价格  比如 -46  46 而实际商品数目是很多的 所以要把当前 减去的值记录下 然后再 加减后去不上差值 标记在模型中
         */
        _model.cancelClickTotals = counts * tempPrice;
        
        ShopCarMGR.globalToolBar.currentTotlasPrice = totals;
        
        ShopCarMGR.globalToolBar.currentSelectedGoodCounts--;
        
        //ShopCarMGR->_selectGoodArray[_model.indexInArray * 2] = 0;
        //[ShopCarMGR->_tempDic setObject:@[@(0),@(0)] forKey:_model];//购物模式下 记录一下
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
