//
//  LBChatListCellModel.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface LBChatListCellModel : NSObject

/** chatType*/
@property(nonatomic,copy) NSString *chatType;

/** chatID*/
@property(nonatomic,copy) NSString *chatID;

/** head icon*/
@property(nonatomic,copy) NSString *icon;
@end
