//
//  RRJJButton.m
//  newrrjj
//
//  Created by   LiuBo on 2017/8/27.
//  Copyright © 2017年 lll. All rights reserved.
//

#import "RRJJButton.h"

RRJJButton *_btn;
@implementation RRJJButton
+ (instancetype)buttonWithIdentify:(NSString *)identify{
    _btn = [self buttonWithType:UIButtonTypeCustom andIdentify:identify];
    return _btn;
}


+ (instancetype)buttonWithType:(UIButtonType)type andIdentify:(NSString *)identify{
    RRJJButton *button = [self buttonWithType:type];
    button->_identify = identify;
    return button;
    
}






#pragma mark -- 链式
+ (instancetype)rrjjBtnMaker:(void(^)(RRJJButton *button))maker{
    _btn = [self buttonWithType:UIButtonTypeCustom];
    maker(_btn);
    return _btn;
}

- (RRJJButton *(^)(NSString *title, UIControlState state, ...))title{
    RRJJButton *(^block)(NSString *title, UIControlState state,...) = ^(NSString * title, UIControlState state,...){
        [self setTitle:title forState:state];
        va_list argList;
        
        @try {
            va_start(argList, state);
            UIColor *color = va_arg(argList, id);
            [self setTitleColor:color forState:state];
        } @catch (NSException *exception) {
            
        } @finally {
            va_end(argList);
        }
        
        return self;
    };
    return block;
}



/** image*/
- (RRJJButton *(^)(UIImage *image, UIControlState state))img{
    RRJJButton *(^block)(UIImage *image, UIControlState state) = ^(UIImage * image, UIControlState state){
        [self setImage:image forState:state];
        return self;
    };
    return block;
}



/** 背景图片*/
- (RRJJButton *(^)(UIImage *image, UIControlState state))bgImg{
    RRJJButton *(^block)(UIImage *bgImg, UIControlState state) = ^(UIImage * bgImg, UIControlState state){
        [self setBackgroundImage:bgImg forState:state];
        return self;
    };
    return block;
}

/** 背景颜色*/
- (RRJJButton *(^)(UIColor *bgColor))bgColor{
    RRJJButton *(^block)(UIColor *bgColor) = ^(UIColor * bgColor){
        self.backgroundColor = bgColor;
        return self;
    };
    return block;
}


- (RRJJButton *(^)(NSString *identify))ID{
    RRJJButton *(^block)(NSString *ID) = ^(NSString * ID){
        self->_identify = ID;
        return self;
    };
    return block;
}


/** 回调*/
- (RRJJButton *(^)(Btnlock clickBtn))clickBtn{
    __weak typeof(self) _weakSelf = self;
    RRJJButton *(^block)(Btnlock clickBtn) = ^(Btnlock clickBtn){
        
        _weakSelf.block = clickBtn;
        return self;
    };
    return block;
}





#pragma mark *************** 重载
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    __weak typeof(self) _weakSelf = self;
    self.block(_weakSelf);
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqualToString:@"_identify"] || [key isEqualToString:@"identify"]) return;
    @try {
        [super setValue:value forKey:key];
    } @catch (NSException *exception) {
        NSLog(@"没找到key");
    } @finally {
        NSLog(@"回去");
    }
    
        
    
}



@end
