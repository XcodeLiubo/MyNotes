//
//  LBChatDetailVC.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/9.
//  Copyright © 2017年 LiuBo. All rights reserved.
//


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"

#import <MJRefresh/MJRefresh.h>
#import <sqlite3.h>


#import "LBChatDetailVC.h"
#import "LBChatDetailCell.h"
#import "LBChatDetailManager.h"
#import "LBChatDetailCellModel.h"
#import "NSObject+LBModelQuicklyCreate.h"


/** 这个如果这个界面写好了 这个类用来封装的 以后做*/
#define mine [LBChatDetailManager shareChatDetailVCMGR]

NSString * const keyTotals = @"totals";

@interface LBChatDetailVC ()<UITableViewDelegate, UITableViewDataSource>
{
    sqlite3 *_db_chat_server;                   //模拟服务器的数据库
    sqlite3 *_db_chat_local_history;            //本地历史数据库
    BOOL _isOpenServerSql;
    
    
    dispatch_source_t _gcd_timer;               //GCD 定时器 请求最新数据
    dispatch_queue_t _request_last_msg_queue;
    
    
    NSDictionary *_serverTotalsDic;             //服务器存储的每次返回的消息量, 这里是模拟
    NSInteger _allMsgs;                         //取到服务器返回的数据量 有新消息就会被覆盖 会变化的
    
    
    
    bool _isfirstInChatPage;                    //是否第一次进入聊天界面
    NSInteger _didLoadHistoryMsgs;              //已经加载了多少条历史记录了
    
}

/** dataSource*/
@property(nonatomic,strong) NSMutableArray<LBChatDetailCellModel *> *dataSource;

/** table*/
@property(nonatomic,weak) UITableView *tableView;
@end

@implementation LBChatDetailVC
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    sqlite3_close(_db_chat_server);
    sqlite3_close(_db_chat_local_history);
    dispatch_suspend(_gcd_timer);
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUPUI];
    
    //请求数据
    //[self requestLastInfo];
    
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
    
    [self initData];
}


- (void)createTable{
    [self tableView];
}

- (void)createKeyBoard{
    //创建自定义的键盘
}


#pragma mark *************** 初始化一些成员变量
- (void)initData{
    _serverTotalsDic = [NSMutableDictionary dictionary];
    //假设现在数据源存储的总量是 626 这里是模拟
    [_serverTotalsDic setValue:@"626" forKey:keyTotals];
    
    
    
    //打开模拟的服务器的数据库
    _isOpenServerSql = NO;
    char const *sqlServerPath = "/Users/liubo/Desktop/聊天数据/lbChat.sqlite";
    int result = sqlite3_open(sqlServerPath, &_db_chat_server);
    if(result == SQLITE_OK){
        _isOpenServerSql = YES;
    }else{
        _isOpenServerSql = NO;
    }
    
    
    
    //打开本地历史的数据库
    NSString *sqlLocalHistoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    sqlLocalHistoryPath = [sqlLocalHistoryPath stringByAppendingPathComponent:@"history_db"];
    
    result = sqlite3_open(sqlLocalHistoryPath.UTF8String, &_db_chat_local_history);
    if(result == SQLITE_OK){
        //建表
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE t_history_chat_%zd(headImg TEXT, createTime TEXT NOT NULL, ID TEXT NOT NULL, memberID TEXT NOT NULL, memberNickName TEXT NOT NULL, msg TEXT NOT NULL, indexrow INTEGER PRIMARY KEY NOT NULL)",123456];
        char *error;
        result = sqlite3_exec(_db_chat_local_history, sql.UTF8String, NULL, NULL, &error);
        if(result == SQLITE_OK){
            //创建队列
            _request_last_msg_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            //默认下拉一次
            _isfirstInChatPage = YES;
            [self requestHistoryMsgs];
            
            
        }else{
            sqlite3_close(_db_chat_local_history);
        }
        
    }else{
        
    }
}

- (void)createGcdTimer{
    dispatch_queue_t queue = dispatch_get_main_queue();
    _gcd_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
    uint64_t interval = (uint64_t)(3.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(_gcd_timer, start, interval, 0);
    
    
    dispatch_source_set_event_handler(_gcd_timer, ^{
        [self requestLastInfo];
    });
}

#pragma mark *************** 定时器请求数据
- (void)requestLastInfo{
    //请求  这里是模拟
    
    dispatch_async(_request_last_msg_queue, ^{
        NSString *sql = [NSString stringWithFormat:@"select * from t_chat limit %zd,%zd",0,20];
        
        sqlite3_stmt *stmt;
        
        //这里模拟的相当于是在请求服务器的数据
        int result = sqlite3_prepare_v2(_db_chat_server, sql.UTF8String, -1, &stmt, NULL);
        
        
        if (result == SQLITE_OK) {
            NSMutableArray *resultArray = [NSMutableArray array];
            while(sqlite3_step(stmt) == SQLITE_ROW){
                
                const unsigned char *time  = sqlite3_column_text(stmt, 1);
                const unsigned char *icon  = sqlite3_column_text(stmt, 2);
                const unsigned char *ID    = sqlite3_column_text(stmt, 3);
                const unsigned char *memID = sqlite3_column_text(stmt, 4);
                const unsigned char *name  = sqlite3_column_text(stmt, 5);
                const unsigned char *msg   = sqlite3_column_text(stmt, 6);
                @autoreleasepool {
                    NSDictionary *dic = @{
                                          @"createTime":[@"" initWithUTF8String:(const char*)time],
                                          @"headImg":[@"" initWithUTF8String:(const char*)icon],
                                          @"id":[@"" initWithUTF8String:(const char*)ID],
                                          @"memberId":[@"" initWithUTF8String:(const char*)memID],
                                          @"memberNickname":[@"" initWithUTF8String:(const char*)name],
                                          @"msg":[@"" initWithUTF8String:(const char*)msg],
                                          };
                    [resultArray addObject:dic];
                }
                
            }
            
            
            //上面的代码是在模拟请求, 这里是请求回来了 到主线程了
            dispatch_async(dispatch_get_main_queue(), ^{
                //表示模拟请求成功
                if(resultArray.count){
                    
                    NSInteger totals = [[_serverTotalsDic objectForKey:keyTotals] integerValue];
                    
                    NSInteger hasNewMsgs = 0;
                    
                    //表示没有新消息 上次记录的和当前返回的 相等
                    if(_allMsgs == totals)
                        return ;
                    else
                        hasNewMsgs = totals - _allMsgs;  //有多少条新消息
                    _allMsgs = totals;
                    
                    /*
                            走到这里表示有新消息
                            要找出 新返回的数据的最旧(下表最大的)的那条在 原来数据源的第几条  就上上面定义的局部变量 hasNewMsgs
                     
                            找到的话: hasNewMsgs <= 20
                                将新来的20条数据覆盖到原来数据源中找到的下标开始的后面
                     
                            没找到 (表示数据断层了) hasNewMsgs > 20
                                插入到原来数据源的最后面
                        */
                    
                    if(hasNewMsgs > 20)//断层 直接加到数据源的末尾 20条
                        hasNewMsgs = resultArray.count;
                    
                    for (NSInteger k = hasNewMsgs - 1; k >= 0; k--) {
                        NSDictionary *dic = resultArray[k];
                        LBChatDetailCellModel *model = [LBChatDetailCellModel modelWithDic:dic];
                        model.indexInAllMsgs = _allMsgs - k;  //记录第几条消息
                        [_dataSource addObject:model];
                    }
                    
                    //保存到数据库中
                    [self saveMsgs:[_dataSource subarrayWithRange:NSMakeRange(_dataSource.count - 20, 20)]];
                    
                    [self.tableView reloadData];
                }else{
                    //表示模拟请求失败
                }
               
            });
            
        }
    });
}




#pragma mark *************** 下拉刷新 加载历史数据 最复杂
NSInteger _page_now = 0;
NSInteger _offset = 20;
- (void)requestHistoryMsgs{
    
    if(_isfirstInChatPage){
        [self requestLastInfo];
    }
    dispatch_async(_request_last_msg_queue, ^{
        NSString *sql = [NSString stringWithFormat:@"select * from t_chat limit %zd,%zd",_page_now * _offset,_offset];
        
        sqlite3_stmt *stmt;
        int result = sqlite3_prepare_v2(_db_chat_server, sql.UTF8String, -1, &stmt, NULL);
        
        
        if (result == SQLITE_OK) {
            NSMutableArray *resultArray = [NSMutableArray array];
            while(sqlite3_step(stmt) == SQLITE_ROW){
                
                const unsigned char *time  = sqlite3_column_text(stmt, 1);
                const unsigned char *icon  = sqlite3_column_text(stmt, 2);
                const unsigned char *ID    = sqlite3_column_text(stmt, 3);
                const unsigned char *memID = sqlite3_column_text(stmt, 4);
                const unsigned char *name  = sqlite3_column_text(stmt, 5);
                const unsigned char *msg   = sqlite3_column_text(stmt, 6);
                @autoreleasepool {
                    NSDictionary *dic = @{
                                          @"createTime":[@"" initWithUTF8String:(const char*)time],
                                          @"headImg":[@"" initWithUTF8String:(const char*)icon],
                                          @"id":[@"" initWithUTF8String:(const char*)ID],
                                          @"memberId":[@"" initWithUTF8String:(const char*)memID],
                                          @"memberNickname":[@"" initWithUTF8String:(const char*)name],
                                          @"msg":[@"" initWithUTF8String:(const char*)msg],
                                          };
                    [resultArray addObject:dic];
                }
                
            }
            
            
            //上面的代码是在模拟请求, 这里是请求回来了 到主线程了
            dispatch_async(dispatch_get_main_queue(), ^{
                if(resultArray.count){ //表示模拟请求成功
                    
                    
                    if(_isfirstInChatPage){ //如果是第一次 就先将数据展示到界面上
                        
                        //获取返回的总数
                        _allMsgs = [_serverTotalsDic[keyTotals] integerValue];
                        
                        
                        //解析数据
                        for (NSInteger k = resultArray.count -1; k>=0; k--) {
                            @autoreleasepool {
                                NSDictionary *dic = resultArray[k];
                                LBChatDetailCellModel *model = [LBChatDetailCellModel modelWithDic:dic];
                                model.indexInAllMsgs = _allMsgs - k - 1; //是所有记录中的哪一条
                                [self.dataSource addObject:model];
                            }
                        }
                        
                        //展示 并且滚动到最底部
                        [self.tableView reloadData];
                        
#warning 滚动的代码 但是就是滚不到最后去
                        NSIndexPath *path = [NSIndexPath indexPathForRow:resultArray.count -1 inSection:0];
                        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        
                        
                        
                        //存储到数据库(很复杂)  传的是最旧的数据
                        //[self findLastNewMsgInHistoryDBIndexWithModel:_dataSource[0]];
                        //将20条数据存储到数据库中
                        [self saveMsgs:resultArray];
                        
                        
                        //创建定时器
                        [self createGcdTimer];
                        
                        _isfirstInChatPage = NO;
                    }else{//下拉的时候回走这里
                        
                        
                        
                        //先从数据库中拿历史记录
                        
                        
                        
                        //拿不到去请求
                    }
                    
                    
                    
                    
                    //情况1 假设服务器返回的数据(20条最新消息的) "最老" 的那一条就是  本地数据库里最后的那一条  直接本地数据库的 最后一条 接上去这最新的20条
                    
                    //情况2 假设服务器返回的数据(20条最新消息的) "最老" 的那一条和本地 数据库中最后20条数据 重叠了(一定在最后的20条之间的哪一条重叠) 找出重叠的并删除本地数据库中重叠处下表的后面的的数据 直接从重叠的下标之后接上去这最新的20条
                    
                    
                    //情况2 假设服务器返回的数据 20条最新消息中的 "最老" 的那一条 在本地数据库没有找到 要算出 这最老的一条数据  和 本地数据库中 最后一条数据的 间隔是多少
                    
                    
                    
                    
                    //以上是服务器返回的数据 和 本地历史数据 会出现的情况 但还有一种更恶心的情况
                    
                    /*
                            最恶心 如果用户第一次下载app进来到聊天的界面
                            1>  我将服务器返回的20条数据 存储到本地的数据库中
                            
                            
                     
                            2>  这个时候, 假如用户出去了这个页面
                            
                            3>  然后隔了一段时间再进来
                     
                            4>  我又将这次服务器返回的数据存储到数据库中
                                > 这个时候, 可能出现上面的情况2(因为他出去聊天页面的这段时间 可能服务器有很多消息了), 出现第1个间隔
                     
                            
                     
                            
                            5>  假如 用户又出去了....
                            
                            6>  然后又隔了一段很长的时间又进来了
                     
                            7>  我又将这次服务器返回的数据存储到数据库中
                                >这个时候, 可能出现上面的情况2(因为他出去聊天页面的这段时间 可能服务器有很多消息了), 出现第2个间隔
                     
                     
                            8> 继续重复 2 3 4 这几步....
                     
                     
                     
                     
                        */
                    
                    
                    
                    
                    
                    
                    
                }else{
                    //表示模拟请求失败
                }
                
            });
            
        }
    });

}



/** 找到要存储的目标位置*/
- (void)findLastNewMsgInHistoryDBIndexWithModel:(LBChatDetailCellModel *)model{
    //insert OR IGNORE into fdsfa(dgh) values(4);
    
}

/** 插入记录到数据库*/
- (void)saveMsgs:(NSArray<LBChatDetailCellModel *> *)array{
    //insert OR IGNORE into fdsfa(dgh) values(4);
    NSMutableString *sql = [@"insert OR IGNORE into t_history_chat_123456(headImg,createTime,id,memberID,memberNickName,msg,indexrow) values" mutableCopy];
    for (NSInteger k = 0; k < array.count; k++) {
        @autoreleasepool {
            LBChatDetailCellModel *model = array[k];
            NSString *str = [NSString stringWithFormat:@"(%@,%ld,%zd,%zd,%@,%@,%zd),",model.iconUrl,model.time,model.friendID,model.friendID,model.nickName,model.content,model.indexInAllMsgs];
            [sql appendString:str];
        }
    }
    [sql deleteCharactersInRange:NSMakeRange(sql.length-1, 1)];
    [sql appendString:@";"];
    int result = sqlite3_exec(_db_chat_local_history, sql.UTF8String, NULL, NULL, NULL);
    if(result == SQLITE_OK){
        
    }else{
        
    }
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
                view.init_frame(self.view.bounds).init_bgColor([UIColor clearColor]).init_h(self.view.h - 108);
                view.delegate = self;
                view.dataSource = self;
                view.showsHorizontalScrollIndicator = NO;
                view.separatorStyle = UITableViewCellSeparatorStyleNone;
                view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    [self requestHistoryMsgs];
                }];
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
    NSLog(@"%zd",indexPath.row);
    LBChatDetailCellModel *model = self.dataSource[indexPath.row];
    LBChatDetailCell *cell = [LBChatDetailCell cellWithTable:tableView model:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    LBChatDetailCellModel *model = self.dataSource[indexPath.row];
    return model.cellH;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
@end



#pragma clang diagnostic pop
