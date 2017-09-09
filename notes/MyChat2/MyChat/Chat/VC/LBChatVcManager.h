//
//  LBChatVcManager.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LBChatListCellModel;

@interface LBChatVcManager : NSObject
/** 单例*/
+ (instancetype)shareChatVcMGR;

/** 复用cell*/
- (__kindof UITableViewCell *)cellWithTable:(UITableView *)table model:(LBChatListCellModel *)model;

/** 打开选中的聊天人的 详细聊天界面*/
- (void)pushChatSelectedChatToDetailVCWith:(LBChatListCellModel *)model VC:(__kindof UINavigationController *)nav;



@end
