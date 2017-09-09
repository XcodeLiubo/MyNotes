//
//  LBChatDetailCell.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LBChatDetailCellModel;
@interface LBChatDetailCell : UITableViewCell
+ (instancetype)cellWithTable:(UITableView *)table model:(LBChatDetailCellModel *)model;
@end
