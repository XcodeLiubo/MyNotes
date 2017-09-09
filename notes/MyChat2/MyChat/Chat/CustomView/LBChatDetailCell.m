//
//  LBChatDetailCell.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#define MAS_SHORTHAND
//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS



#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

#import "LBChatDetailCell.h"
#import "LBChatDetailCellModel.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"

@interface LBChatDetailCell ()
{
    UIImageView *_currentImgView;
    UILabel     *_currentNameLab;
    UIButton    *_currentContentBtn;
}
/** 发送的时间*/
@property(nonatomic,weak) UILabel *sendTimeLab;

/** icon imgView*/
@property(nonatomic,weak) UIImageView *icon;

/** name Lab*/
@property(nonatomic,weak) UILabel *nameLab;

/** master Lab 相当于操盘人*/
@property(nonatomic,weak) UILabel *mainLab;

/** 内容 button*/
@property(nonatomic,weak) UIButton *contentBtn;

/** my icon imgView*/
@property(nonatomic,weak) UIImageView *myIcon;

/** my name Lab*/
@property(nonatomic,weak) UILabel *myNameLab;

/** my content button*/
@property(nonatomic,weak) UIButton *myContentBtn;
@end


@implementation LBChatDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
}



- (instancetype)initWithFrame:(CGRect)frame{
    return ((self = [super initWithFrame:frame]),
            (self == nil?:[self setUPUI]),
            self);
}

- (void)setUPUI{
    _sendTimeLab = ({
        
        UILabel *label = [self labelWithFont:12 textAlignment:NSTextAlignmentCenter numberOfLines:1 textColor:[UIColor whiteColor] backGroundColor:[UIColor grayColor]];
        
        [self.contentView addSubview:label];
        label;
    });
    
    _icon = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    _nameLab = ({
        UILabel *label = [self labelWithFont:13 textAlignment:NSTextAlignmentLeft numberOfLines:1 textColor:nil backGroundColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:label];
        label;
    });
    
    _contentBtn = ({
        UIButton *button = [self buttonWithType:UIButtonTypeCustom fontSize:14 numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        
        [self.contentView addSubview:button];
        button;
    });
    
    
    _myIcon = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        
        [self.contentView addSubview:imageView];
        imageView;
    });
    
    _myNameLab = ({
        UILabel *label = [self labelWithFont:13 textAlignment:NSTextAlignmentLeft numberOfLines:1 textColor:nil backGroundColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:label];
        label;
    });
    
    _myContentBtn = ({
        UIButton *button = [self buttonWithType:UIButtonTypeCustom fontSize:14 numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        
        [self.contentView addSubview:button];
        button;
    });
    
    [self masonry];
}


#pragma mark *************** Masonry
- (void)masonry{
   __block CGFloat offset = 10, top_offset = 5;
     CGFloat h = 22, icon_wh = 50;
    
    [_sendTimeLab makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(h);
        make.centerX.offset(0);
        make.top.offset(top_offset);
        make.width.greaterThanOrEqualTo(20);
    }];
    
    
    [_icon makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.equalTo(icon_wh);
        make.left.offset(offset);
        
        top_offset = top_offset + 3;
        make.top.offset(top_offset);
    }];
    
    [_nameLab makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(h);
        make.width.greaterThanOrEqualTo(40);    offset = 8;
        make.left.equalTo(_icon.right).offset(offset);
        make.top.equalTo(_icon).offset(0);
        
    }];
    
    [_contentBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_nameLab.bottom).offset(offset);
        make.left.equalTo(_nameLab.left);
        make.width.lessThanOrEqualTo(SCREEN_W * 2/3);
    }];
    
    
    
    [_myIcon makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_icon).offset(0);
        offset = 10;
        make.right.offset(-offset);
        make.width.height.equalTo(_icon);
    }];
    
    [_myNameLab makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_nameLab);
        make.right.equalTo(_myIcon.left).offset(-8);
        make.width.greaterThanOrEqualTo(40);
    }];
    
    [_myContentBtn makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_contentBtn);
        make.right.equalTo(_myNameLab);
        make.width.lessThanOrEqualTo(SCREEN_W * 2/3);
    }];
    
}






- (void)setModel:(LBChatDetailCellModel *)model{
    _model = model;
    
    if(model.isMe){
        _currentImgView = _myIcon, _currentNameLab = _myNameLab, _currentContentBtn = _myContentBtn;
        _icon.hidden = _nameLab.hidden = _contentBtn.hidden = YES;
    }else{
        _currentImgView = _icon, _currentNameLab = _nameLab, _currentContentBtn = _myContentBtn;
        _myIcon.hidden = _myNameLab.hidden = _myContentBtn.hidden = YES;
    }
    
    _currentContentBtn.hidden = _currentNameLab.hidden = _currentImgView.hidden = NO;
    
    
    self.sendTimeLab.text = model.time;
    
    UIImage *defaultImage = [UIImage imageNamed:placeholderName];
    [_currentImgView sd_setImageWithURL:model.iconUrl placeholderImage:defaultImage];
    
    _currentNameLab.text = model.nickName;
    
    [_currentContentBtn setTitle:model.content forState:UIControlStateNormal];
    
    
}


#pragma mark -- 工具方法
- (UILabel *)labelWithFont:(CGFloat )fontSize textAlignment:(NSTextAlignment)align numberOfLines:(NSInteger)lines textColor:(UIColor *)textColor backGroundColor:(UIColor *)bgColor{
    UILabel *label = [UILabel createView:^(UILabel *view) {
        view.init_bgColor(bgColor);
        view.font = [UIFont systemFontOfSize:fontSize];
        view.textColor = textColor;
        view.textAlignment = align;
        view.numberOfLines = lines;
    }];
    return label;
}

- (UIButton *)buttonWithType:(UIButtonType)type fontSize:(CGFloat)size numberOfLines:(NSInteger)lines textAlignment:(NSTextAlignment)align{
    UIButton *button = [UIButton createView:^(UIButton *view) {
        [view setValue:@(type) forKey:@"buttonType"];
        view.titleLabel.font = [UIFont systemFontOfSize:size];
        view.titleLabel.numberOfLines = lines;
        view.titleLabel.textAlignment = align;
    }];
    
    return button;
}
@end



#pragma clang diagnostic pop
