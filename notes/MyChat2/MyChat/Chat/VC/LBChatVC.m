//
//  LBChatVC.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//




#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"


#import "LBChatVC.h"
#import "LBChatVcManager.h"
#import "LBChatListCellModel.h"
#import "NSObject+LBModelQuicklyCreate.h"
#define mine [LBChatVcManager shareChatVcMGR]

@interface LBChatVC ()<UITableViewDelegate, UITableViewDataSource>
/** list*/
@property(nonatomic,weak) UITableView *tableView;

/** dataSource*/
@property(nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation LBChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUPUI];
}

#pragma mark *************** UI
- (void)setUPUI{
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"列表";
    
    
    [self createTable];
}


- (void)createTable{
    [self tableView];
}

#pragma mark *************** 懒加载
- (UITableView *)tableView{
    if (!_tableView){
        [UITableView createView:^(UITableView *view) {
            view.init_bgColor([UIColor clearColor]).init_frame(self.view.bounds).init_identify(@"table");
            view.delegate = self;
            view.dataSource = self;
            view.separatorStyle = UITableViewCellSeparatorStyleNone;
            view.showsHorizontalScrollIndicator = NO;
            view.rowHeight = 60;
            [self.view addSubview:view];
            _tableView = view;
        }];
    }
    return _tableView;
}

- (NSMutableArray<LBChatListCellModel *> *)dataArray{
    if (!_dataArray){
        _dataArray = [NSMutableArray array];
        NSArray *list = @[
                          @{@"chatType":@"我自己", @"chatID":@"0", @"icon":@""},
                          @{@"chatType":@"朋友1", @"chatID":@"1", @"icon":@""},
                          @{@"chatType":@"妹妹", @"chatID":@"2", @"icon":@""},
                          @{@"chatType":@"爷爷", @"chatID":@"3", @"icon":@""},
                          @{@"chatType":@"同学1", @"chatID":@"4", @"icon":@""},
                          @{@"chatType":@"队友", @"chatID":@"5", @"icon":@""},
                          @{@"chatType":@"群聊", @"chatID":@"6", @"icon":@""}
                          ];
        for (NSDictionary *dic in list) {
            [_dataArray addObject:[LBChatListCellModel modelWithDic:dic]];
        }
        
    }
    return self->_dataArray;
}


#pragma mark -- table 的代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [mine cellWithTable:tableView model:_dataArray[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LBChatListCellModel *model = self.dataArray[indexPath.row];
    
    [mine pushChatSelectedChatToDetailVCWith:model VC:self.navigationController];
}





@end










#pragma clang diagnostic pop

















