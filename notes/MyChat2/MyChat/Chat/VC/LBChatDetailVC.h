//
//  LBChatDetailVC.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBChatDetailVC : UIViewController
/** 聊天的id */
@property(nonatomic,copy) NSString *chatID;

/** 聊天对象*/
@property(nonatomic,copy) NSString *chatType;
@end
