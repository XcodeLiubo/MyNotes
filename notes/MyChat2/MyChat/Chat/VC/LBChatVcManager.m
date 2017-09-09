//
//  LBChatVcManager.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"

#import <UIImageView+WebCache.h>


#import "LBChatVcManager.h"
#import "LBChatDetailVC.h"
#import "LBChatListCellModel.h"

static LBChatVcManager *_mgr;

@implementation LBChatVcManager


#pragma mark *************** 单例
+ (instancetype)shareChatVcMGR{
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


#pragma mark -- Public
static NSString * const cellID = @"chatCell";
- (__kindof UITableViewCell *)cellWithTable:(UITableView *)table model:(LBChatListCellModel *)model{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self setChatInfoWith:cell model:model];
    return cell;
}



- (void)setChatInfoWith:(__kindof UITableViewCell *)cell model:(LBChatListCellModel *)model{
    UIImage *image = [UIImage imageNamed:@"placeholder"];
    cell.imageView.image = image;
    cell.textLabel.text = model.chatType;
    
}



- (void)pushChatSelectedChatToDetailVCWith:(LBChatListCellModel *)model VC:(__kindof UINavigationController *)nav{
    
    LBChatDetailVC *chatDetailVC = [[LBChatDetailVC alloc] init];
    chatDetailVC.chatType   =   model.chatType;
    chatDetailVC.chatID     =   model.chatID;
    
    [nav pushViewController:chatDetailVC animated:YES];
}

@end
#pragma clang diagnostic pop






