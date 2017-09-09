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
#import "LBChatDetailCellModel.h"
#import "NSObject+LBModelQuicklyCreate.h"


#define mine [LBChatDetailManager shareChatDetailVCMGR]


@interface LBChatDetailVC ()<UITableViewDelegate, UITableViewDataSource>
/** dataSource*/
@property(nonatomic,strong) NSMutableArray<LBChatDetailCellModel *> *dataSource;

/** table*/
@property(nonatomic,weak) UITableView *tableView;
@end

@implementation LBChatDetailVC
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPUI];
    
    //请求数据
    [self request];
    
}


#pragma mark *************** UI
- (void)setUPUI{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = self.chatType;
    self.navigationController.toolbarHidden = NO;
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



#pragma mark *************** 请求数据
- (void)request{
    //先从本地数据库度
    
    
    //请求  这里是模拟
    NSString *path = [[NSBundle mainBundle] pathForResource:@"history.plist" ofType:nil];
    NSArray *chatListArr = [NSArray arrayWithContentsOfFile:path];
    for (NSDictionary *dic in chatListArr) {
        LBChatDetailCellModel *model = [LBChatDetailCellModel modelWithDic:dic];
        [self.dataSource addObject:model];
    }
    assert(1);
}


#pragma mark *************** 数据源
- (NSMutableArray<LBChatDetailCellModel *> *)dataSource{
    if (!_dataSource){
        self->_dataSource = [NSMutableArray<LBChatDetailCellModel *> array];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LBChatDetailCellModel *model = self.dataSource[indexPath.row];
    LBChatDetailCell *cell = [LBChatDetailCell cellWithTable:tableView model:model];
    return cell;
}

@end



#pragma clang diagnostic pop
