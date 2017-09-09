//
//  LBChatDetailVC.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"


#import "LBChatDetailVC.h"
#import "LBChatDetailCell.h"
#import "LBChatDetailManager.h"


#define mine [LBChatDetailManager shareChatDetailVCMGR]


@interface LBChatDetailVC ()<UITableViewDelegate, UITableViewDataSource>
/** dataSource*/
@property(nonatomic,strong) NSMutableArray *dataSource;

/** table*/
@property(nonatomic,weak) UITableView *tableView;
@end

@implementation LBChatDetailVC
static LBChatDetailVC *_chatVC;



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPUI];
    
    //请求数据
    //[self request];
    
}

- (void)setUPUI{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = self.chatType;
    
    //创建表格
    [self createTable];
    
    //创建键盘
    [self createKeyBoard];
}


- (void)createTable{
    [self tableView];
}

- (void)createKeyBoard{
    //创建自定义的键盘
}
#pragma mark *************** 数据源
- (NSMutableArray *)dataSource{
    if (!_dataSource){
        self->_dataSource = [NSMutableArray array];
    }
    return self->_dataSource;
}


- (UITableView *)tableView{
    if (!_tableView){
        self->_tableView = ({
            UITableView *table = [UITableView createView:^(UITableView *view) {
                view.init_frame(self.view.bounds).init_bgColor([UIColor clearColor]).init_h(self.view.h - 44);
                view.delegate = self;
                view.dataSource = self;
                view.showsHorizontalScrollIndicator = NO;
                view.separatorStyle = UITableViewCellSeparatorStyleNone;
                [view registerClass:[LBChatDetailCell class] forCellReuseIdentifier:cellID];
            }];
            [self.view addSubview:table];
            table;
        });
        
    }
    return self->_tableView;
}



#pragma mark -- table代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
static NSString * const cellID = @"chatDetail";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LBChatDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    return cell;
}


















#pragma mark -- 单例
+ (instancetype)shareChatDetailVC{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatVC = [[self alloc] init];
    });
    return _chatVC;
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _chatVC = [super allocWithZone:zone];
    });
    return _chatVC;
}

- (id)copyWithZone:(NSZone *)zone{
    return _chatVC;
}

@end



#pragma clang diagnostic pop
