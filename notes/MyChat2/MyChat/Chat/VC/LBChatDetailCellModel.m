//
//  LBChatDetailCellModel.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "LBChatDetailCellModel.h"

@implementation LBChatDetailCellModel
+ (instancetype)modelWithDic:(NSDictionary *)dic{
    LBChatDetailCellModel *model = OBJC_Model;
    
        model.time  =   [dic[@"createTime"] longLongValue];
    model.friendID  =   [dic[@"memberid"] integerValue];
     model.content  =   dic[@"msg"];
     model.iconUrl  =   dic[@"headImg"];

    //一定要放到 friend 后面 因为依赖于 他的 setter 方法的操作结果
    model.nickName  =   dic[@"memberNickname"];
    
    return model;
}


- (void)setIconUrl:(NSString *)iconUrl{
    if(!iconUrl.length)return;
    
    _iconUrl = [iconUrl hasPrefix:@"http"] ?iconUrl:[@"https://www.rrjj.com" stringByAppendingString:iconUrl];
}

- (void)setFriendID:(NSInteger)friendID{
    _me = NO;
    
    if(friendID < 0) return;
    
    _friendID = friendID;
    
    if(friendID == [UserID integerValue])    _me = YES;
}

- (void)setNickName:(NSString *)nickName{
    if(!nickName)return;
    
    _stockOperation = NO;
    
    if(!self.isMe && Objc_same(nickName, UserName)) _stockOperation = YES;
}

- (void)setTime:(long)time{
    if(time == 0)return;
    
    _time = time;
    
    if(_time_now() - time < dayMS){ //小于一天
        _showTime = dateStr(time / 1000, true);
    }else{
        _showTime = dateStr(time / 1000, false);
    }
}

@end
