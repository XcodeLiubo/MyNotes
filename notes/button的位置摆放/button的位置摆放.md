#button的位置摆放
### 示例代码
```objc
//
//  SYMeCenterVC.m
//  个人中心
//
//  Created by Liubo on 2017/10/3.
//  Copyright © 2017年 LB. All rights reserved.
//

#import "SYMeCenterVC.h"

@interface SYMeCenterVC ()

@end

@implementation SYMeCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor blueColor];
    button.alpha = 0.7;
    CGRect rect = CGRectMake(100, 100, 50, 50);
    
    UIImage *image = [UIImage imageNamed:@"Snip20171003_2"];
    
    
    
    
    [button setTitle:@"abc" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button.titleLabel sizeToFit];
    [button setImage:image forState:UIControlStateNormal];
    
#if 0  //左右交换文字和图片  文左图右边
    rect.size.width = image.size.width + button.titleLabel.frame.size.width;
    rect.size.height = image.size.height;
    button.frame = rect;
    CGFloat titleW = button.titleLabel.frame.size.width;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, image.size.width);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, titleW, 0 , -titleW);
    
    
#elif 0  //文上图下
    CGFloat titleH = button.titleLabel.frame.size.height;
    rect.size.width = image.size.width;
    rect.size.height = image.size.height + titleH;
    button.frame = rect;
    button.titleEdgeInsets = UIEdgeInsetsMake(-image.size.height , -image.size.width, 0,0);
    button.imageEdgeInsets = UIEdgeInsetsMake(titleH, 0, - titleH, 0);
    
    
#elif 1 //文下图上
    CGFloat titleH = button.titleLabel.frame.size.height;
    rect.size.width = image.size.width;
    rect.size.height = image.size.height + titleH;
    button.frame = rect;
    button.titleEdgeInsets = UIEdgeInsetsMake(0 , -image.size.width, -image.size.height,0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-titleH, 0,  titleH, 0);
#endif
    [self.view addSubview:button];
    
}




@end

```