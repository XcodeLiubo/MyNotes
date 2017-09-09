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
- (__kindof UITableViewCell *)cellWithTable:(UITableView *)table{
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        UILabel *nameLab = [[UILabel alloc] init];
        nameLab.tag = 100;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:nameLab];
        
        
        imageView.frame = CGRectMake(10, 10, 50, 50);
        nameLab.frame = CGRectMake(cell.contentView.w - 10, imageView.y, 50, 21);
        nameLab.c_y = cell.contentView.c_y;
        
        nameLab.font = [UIFont systemFontOfSize:12];
        nameLab.textAlignment = NSTextAlignmentRight;
        nameLab.numberOfLines = 0;
        
    }
    return cell;
}



- (void)setChatInfoWith:(__kindof UITableViewCell *)cell data:(__kindof NSArray *)dataArray index:(NSIndexPath *)indexPath{
    NSDictionary *dic = dataArray[indexPath.row];
    
    if(!cell.identifyID){
        cell.init_identify(dic[@"chatID"]);
    }
    
    
    //NSURL *iconUrl = [NSURL URLWithString:dic[@"icon"]];
    UIImage *image = [UIImage imageNamed:@"placeholder"];
    cell.imageView.image = image;
    //[cell.imageView sd_setImageWithURL:iconUrl placeholderImage:image];
    
    NSString *type = dic[@"chatType"];
    CGSize size = [type boundingRectWithSize:CGSizeMake(MAXFLOAT, 21) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]}  context:nil].size;
    UILabel *label = [cell.contentView viewWithTag:100];
    label.text = type;
    label.frame = CGRectMake(label.x, label.y, size.width, size.height);
    cell.contentView.h = label.m_y + 10;
    cell.bounds = cell.contentView.bounds;
    [cell layoutIfNeeded];
    
}



- (void)pushChatSelectedChatToDetailVCWith:(UITableViewCell *)cell VC:(__kindof UINavigationController *)nav{
    
    LBChatDetailVC *chatDetailVC = [LBChatDetailVC shareChatDetailVC];
    chatDetailVC.chatID = cell.identifyID;
    chatDetailVC.chatType = [[UIView viewWithIdentify:@"name"] text];
    [nav pushViewController:chatDetailVC animated:YES];
}

@end
#pragma clang diagnostic pop






