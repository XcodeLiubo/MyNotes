//
//  LBChatDetailCellModel.h
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LBChatDetailCellModel : NSObject

/** 消息发送的时间*/
@property(nonatomic,assign) long time;

/** 发送人的id*/
@property(nonatomic,assign) NSInteger friendID;

/** icon*/
@property(nonatomic,copy) NSString *iconUrl;

/** name*/
@property(nonatomic,copy) NSString *nickName;

/** 聊天的内容*/
@property(nonatomic,copy) NSString *content;


//附加
/** cell的高度*/
@property(nonatomic,assign) CGFloat cellH;

/** me or other*/
@property(nonatomic,assign,getter=isMe) BOOL me;

/** 是否操盘人*/
@property(nonatomic,assign,getter=isStockOperation) BOOL stockOperation;

/** should show time*/
@property(nonatomic,copy) NSString *showTime;

/** 所有的记录中的哪一条 这个值是不会改变的  是自己手动算出来的*/
@property(nonatomic,assign) NSInteger indexInAllMsgs;

@end
