//
//  TestVC.m
//  test
//
//  Created by   LiuBo on 2017/8/28.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "TestVC.h"
#import "RRJJButton.h"
#import "UIView+RRJJ_View.h"

@interface TestVC ()

@end

@implementation TestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [RRJJButton rrjjBtnMaker:^(RRJJButton *button) {
        button.title(@"nihao",UIControlStateNormal,[UIColor redColor]).bgColor([UIColor blueColor]).
        clickBtn(^(RRJJButton *obj){
            NSLog(@"xxxxx %@  %@",obj,obj.identify);
        }).ID(@"我我我我哦");
        button.x = 10;
        button.y = 10;
        button.width =100;
        button.height = 100;
        [button setValue:@"nihnoinadf" forKey:@"identity"];
        [self.view addSubview:button];
        
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
