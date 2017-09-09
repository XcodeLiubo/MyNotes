//
//  LBChatDetailManager.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "LBChatDetailManager.h"

@implementation LBChatDetailManager


#pragma mark -- 单例
static LBChatDetailManager *_mgr;
+ (instancetype)shareChatDetailVCMGR{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mgr = [[self alloc] init];
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

- (id)copyWithZone:(NSZone *)zone{
    return _mgr;
}

@end
