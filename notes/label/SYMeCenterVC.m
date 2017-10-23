//
//  SYMeCenterVC.m
//  个人中心
//
//  Created by Liubo on 2017/10/3.
//  Copyright © 2017年 LB. All rights reserved.
//

#import "SYMeCenterVC.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"


@interface SYMeCenterVC ()

@end

@implementation SYMeCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUPUI];
}

- (void)setUPUI{
    
#if 0  //sizetofit 自动填充会算出 size
    UILabel *label = [[UILabel alloc] init];
    label.text = @"my name is liubo, what's your name? ";
    label.backgroundColor = [UIColor redColor];
    label.contentMode = UIViewContentModeLeft;
    [label sizeToFit]; //这句话不写就没有尺寸
    CGRect rect = (CGRect){0,0,label.frame.size.width,label.frame.size.height};
    rect.origin.x = 20;
    rect.origin.y = 200;
    label.frame = rect;
    
    
#elif 0  //换行模式 必须指定 numberoflines = 0 下面换行的时候 如果不够再显示一个单词就换行了
    UILabel *label = [[UILabel alloc] init];
    label.text = @"my name is liubo, what's your name? ";
    label.backgroundColor = [UIColor redColor];
    //[label sizeToFit];
    label.numberOfLines = 0;
    label.frame = CGRectMake(10, 100, 130, 130);
    //label.lineBreakMode = NSLineBreakByWordWrapping; //NSLineBreakByClipping                 //不够一个单词就换行
    label.lineBreakMode = NSLineBreakByCharWrapping;                    //不够一个字符就换行
    //NSLineBreakByTruncatingHead                   // @"......要结束的内容"
    //NSLineBreakByTruncatingTail                   // @"开始的一部分内容....."
    //NSLineBreakByTruncatingMiddle                 // @"开始的一部分内容....快结束的内容"
    
    
    
#elif 1  //设置 adjustsfontsizefitwidth后 设置中线对其
    UILabel *label = [[UILabel alloc] init];
    label.text = @"my name is liubo, what's your name? ";
    label.backgroundColor = [UIColor redColor];
    label.frame = CGRectMake(10, 100, 220, 100);
    label.adjustsFontSizeToFitWidth = YES;
    label.baselineAdjustment = UIBaselineAdjustmentNone;  //文字底部与lable的中线对其
    //UIBaselineAdjustmentAlignCenters 文字中心与lab的中线对齐
    //UIBaselineAdjustmentAlignBaselines 默认的 文字上端与lab的中线对齐
    
#endif
   
    [self.view addSubview:label];
    NSLog(@"%@",NSStringFromCGRect(label.frame));
}


@end

#pragma clang diagnostic pop
