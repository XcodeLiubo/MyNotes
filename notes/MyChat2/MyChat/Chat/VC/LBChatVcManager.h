//
//  LBChatVcManager.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBChatVcManager : NSObject
/** 单例*/
+ (instancetype)shareChatVcMGR;

- (__kindof UITableViewCell *)cellWithTable:(UITableView *)table;

/** 给cell 设置数据*/
- (void)setChatInfoWith:(__kindof UITableViewCell *)cell data:(__kindof NSArray *)dataArray index:(NSIndexPath *)indexPath;

/** 打开选中的聊天人的 详细聊天界面*/
- (void)pushChatSelectedChatToDetailVCWith:(UITableViewCell *)cell VC:(__kindof UINavigationController *)nav;



@end
