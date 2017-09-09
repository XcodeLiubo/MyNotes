//
//  UIControl+LBControl.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/8.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "UIControl+LBControl.h"
#import <objc/runtime.h>
static void *objc_control_new_instance_block = &objc_control_new_instance_block;
@implementation UIControl (LBControl)

- (instancetype(^)(ControlBlock value))block{
     __weak typeof(self) weakSelf = self;
    UIControl *(^block)(ControlBlock value) = ^(ControlBlock value){
        objc_setAssociatedObject(self, objc_control_new_instance_block, value, OBJC_ASSOCIATION_COPY_NONATOMIC);
        return weakSelf;
    };
    return block;
}


- (ControlBlock)actionBlock{
    return objc_getAssociatedObject(self, objc_control_new_instance_block);
}

- (void)setActionBlock:(ControlBlock)actionBlock{
    objc_setAssociatedObject(self, objc_control_new_instance_block, actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(event.type == UIEventTypeTouches){
        __weak typeof(self) weakSelf = self;
        self.actionBlock(weakSelf);
    }
    
}
@end
