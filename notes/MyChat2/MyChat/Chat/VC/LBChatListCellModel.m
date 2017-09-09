//
//  LBChatListCellModel.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "LBChatListCellModel.h"
//@{@"chatType":@"我自己", @"chatID":@"0", @"icon":@""},
@implementation LBChatListCellModel
+ (instancetype)modelWithDic:(NSDictionary *)dic{
    LBChatListCellModel *model = [[LBChatListCellModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    return model;
}
@end
