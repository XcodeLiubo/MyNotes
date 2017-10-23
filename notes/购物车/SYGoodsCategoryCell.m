//
//  SYGoodsCategoryCell.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYGoodsCategoryCell.h"

@implementation GoodsCategoryModel
+ (instancetype)modelWithDic:(NSDictionary *)dic{
    GoodsCategoryModel *model = [[self alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}


//算出宽度
- (void)setName:(NSString *)name{
    _name = [name copy];
    //38 12
    _title_W = [Global getSizeOfString:name maxWidth:MAXFLOAT maxHeight:38 withFontSize:12].width;
    if(_title_W < 60) _title_W = 60;
}

@end


@interface TitleBtn : UIButton

@end


@implementation TitleBtn

@end




@interface SYGoodsCategoryCell()
/** 标题 */
@property (nonatomic,strong) TitleBtn *catBtn;

/** 横线 */
@property (nonatomic,strong) UIView *lineView;
@end

static UIButton             *_currentBtn;           //记录 上一个 btn
static UIView               *_currentLineView;      //记录 上一个 下划线
static GoodsCategoryModel   *_currentModel;         //记录 上一个 模型

@implementation SYGoodsCategoryCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.catBtn = [TitleBtn buttonWithType:UIButtonTypeCustom];
        _catBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        _catBtn.selected = NO;
        _catBtn.x = 0;
        _catBtn.y = 0;
        _catBtn.w = frame.size.width;
        _catBtn.h = frame.size.height - 1;
        
        [_catBtn setTitleColor:COLOR(ff0000) forState:UIControlStateSelected];
        [_catBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
        
        [_catBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_catBtn];
        
        
        self.lineView = [[UIView alloc] init];
        _lineView.x = 0;
        _lineView.y = frame.size.height - 1;
        _lineView.w = frame.size.width;
        _lineView.h = 1;
        _lineView.hidden = YES;
        _lineView.backgroundColor = COLOR(ff0000);
        [self.contentView addSubview:_lineView];
    }
    return self;
}

- (void)setModel:(GoodsCategoryModel *)model{
    _model = model;
    [_catBtn setTitle:model.name forState:UIControlStateNormal];
    [_catBtn setTitle:model.name forState:UIControlStateHighlighted];
    
    [_catBtn.titleLabel sizeToFit];
    _lineView.w = _catBtn.titleLabel.w;
    _lineView.x = (self.w - _lineView.w)/2;
    
    
    if(_model.isSelected){
        _lineView.hidden = NO;
        _catBtn.selected = YES;
        
        _currentLineView = _lineView;
        _currentBtn = _catBtn;
        _currentModel = model;
    }else{
        _lineView.hidden = YES;
        _catBtn.selected = NO;
    }
}


- (void)click:(UIButton *)button{
    if(_currentBtn == button)return;
    
    ///上一个 btn 的状态 不选中 并且隐藏 下划线
    _currentBtn.selected = NO;
    _currentLineView.hidden = YES;
    _currentModel.selected = NO;
    
    ///当前 选中的 btn 设置为选中, 显示下划线
    button.selected = YES;
    _lineView.hidden = NO;
    _model.selected = YES;
    
    ///记录当前的  btn 和 下划线
    _currentLineView = _lineView;
    _currentBtn = button;
    _currentModel = _model;
    
    
    __weak typeof(self) weakSelf = self;
    if(_titleClick){
        _titleClick(weakSelf.model.index);
    }
}



@end
