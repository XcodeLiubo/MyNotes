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
#import <SVProgressHUD/SVProgressHUD.h>


#import "LBChatDetailVC.h"
#import "LBChatDetailCell.h"
#import "LBChatDetailManager.h"
#import "LBChatDetailCellModel.h"
#import "NSObject+LBModelQuicklyCreate.h"


/** 这个如果这个界面写好了 这个类用来封装的 以后做*/
#define mine [LBChatDetailManager shareChatDetailVCMGR]


typedef NS_ENUM(NSInteger,EncodeType){
    EncodeTypeServer,
    EncodeTypeLocal
};


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
    NSInteger _firstInpageRecordMsgs;           //只记录进入页面时 服务器返回消息的总量
    
}

/** dataSource*/
@property(nonatomic,strong) NSMutableArray<LBChatDetailCellModel *> *dataSource;

/** table*/
@property(nonatomic,weak) UITableView *tableView;

/** 历史记录表的名字 */
@property (nonatomic,copy) NSString *_t_name;
@end

@implementation LBChatDetailVC
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    sqlite3_close(_db_chat_server);
    sqlite3_close(_db_chat_local_history);
    dispatch_cancel(_gcd_timer);
    _gcd_timer = nil;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(_allMsgs) forKey:self._t_name];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    self._t_name = @"t_history_chat_123456";
    
    _serverTotalsDic = [NSMutableDictionary dictionary];
    //假设现在数据源存储的总量是 626 这里是模拟
    [_serverTotalsDic setValue:@"626" forKey:keyTotals];
    
    
    
    //打开模拟的服务器的数据库
    _isOpenServerSql = NO;
    char const *sqlServerPath = [[NSBundle mainBundle] pathForResource:@"lbChat.sqlite" ofType:nil].UTF8String;
    int result = sqlite3_open(sqlServerPath, &_db_chat_server);
    if(result == SQLITE_OK){
        _isOpenServerSql = YES;
    }else{
        _isOpenServerSql = NO;
    }
    
    
    //创建定时器
    [self createGcdTimer];
    
    
    //打开本地历史的数据库
    NSString *sqlLocalHistoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    sqlLocalHistoryPath = [sqlLocalHistoryPath stringByAppendingPathComponent:@"history_db.sqlite"];
    
    result = sqlite3_open(sqlLocalHistoryPath.UTF8String, &_db_chat_local_history);
    if(result == SQLITE_OK){
        //建表
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE if not exists %@(headImg TEXT, createTime TEXT NOT NULL, ID TEXT NOT NULL, memberID TEXT NOT NULL, memberNickName TEXT NOT NULL, msg TEXT NOT NULL, indexrow INTEGER PRIMARY KEY NOT NULL)",self._t_name];
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

#pragma mark --- gcd定时器
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
        NSString *sql = [NSString stringWithFormat:@"select * from t_chat limit %zd,%zd",0,_offset];
        
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
                    else{
#warning 如果第一次没有消息显示的 没有消息的背景在这里要移除
                        hasNewMsgs = totals - _allMsgs;  //有多少条新消息
                    }
                    
                    _allMsgs = totals;
                    
                    /*
                            走到这里表示有新消息
                            要找出 新返回的数据的最旧(下表最大的)的那条在 原来数据源的第几条  就上上面定义的局部变量 hasNewMsgs
                     
                            找到的话: hasNewMsgs <= 20
                                将新来的20条数据覆盖到原来数据源中找到的下标开始的后面
                     
                            没找到 (表示数据断层了) hasNewMsgs > 20
                                插入到原来数据源的最后面
                        */
                    
                    if(hasNewMsgs > _offset)//断层 直接加到数据源的末尾 20条
                        hasNewMsgs = resultArray.count;
                    
                    for (NSInteger k = hasNewMsgs - 1; k >= 0; k--) {
                        NSDictionary *dic = resultArray[k];
                        LBChatDetailCellModel *model = [LBChatDetailCellModel modelWithDic:dic];
                        model.indexInAllMsgs = _allMsgs - k;  //记录第几条消息
                        [_dataSource addObject:model];
                    }
                    
                    //保存到数据库中 不管有没有重叠或者间隔
                    [self saveMsgs:[_dataSource subarrayWithRange:NSMakeRange(_dataSource.count - _offset, _offset)]];
                    
                    [self.tableView reloadData];
                }else{
                    //表示模拟请求失败
                    [SVProgressHUD showErrorWithStatus:@"网络出错"];
#warning 贴出 网络出错的背景图
                }
               
            });
            
        }
    });
}




#pragma mark *************** 下拉刷新 加载历史数据 最复杂
NSInteger _page_now = 0;
NSInteger _offset = 20;
- (void)requestHistoryMsgs{
    if(_isfirstInChatPage){ //主线程中
        dispatch_async(_request_last_msg_queue, ^{
            NSMutableArray *resultArray = [NSMutableArray array];
            [self requestMsgsArray:&resultArray page:0 offset:_offset];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(resultArray.count && _allMsgs){
                    NSInteger beginIndex = _allMsgs;
                    [self ecodeServerDataWithArray:resultArray beginIndex:beginIndex encodeType:EncodeTypeServer];
                    
                    //展示 并且滚动到最底部
                    [self.tableView reloadData];
                    
#warning 滚动的代码 但是就是滚不到最后去
                    NSIndexPath *path = [NSIndexPath indexPathForRow:resultArray.count -1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    
                    
                    //将20条数据存储到数据库中   //[self findLastNewMsgInHistoryDBIndexWithModel:_dataSource[0]];
                    [self saveMsgs:_dataSource];
                    
                    
                }else{
                    //这里贴出一张背景图 或者直接加载最近的历史记录
                    NSInteger index = [HistoryMsgsMax(self._t_name) integerValue];
                    NSMutableArray *resultArray = [NSMutableArray array];
                    if(index){
                        [self loadHistoryWithIndex:index array:&resultArray];
                        if(resultArray.count){
                            [self ecodeServerDataWithArray:resultArray beginIndex:index encodeType:EncodeTypeLocal];
                            [self.tableView reloadData];
                            
                            //滚动到最后面去
                            NSIndexPath *path = [NSIndexPath indexPathForRow:resultArray.count -1 inSection:0];
                            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        }
                        
                    }else{
                        [SVProgressHUD showInfoWithStatus:@"没有数据"];
                    }
                    
                    
                    
                }
                
                _isfirstInChatPage = NO;
                _didLoadHistoryMsgs = resultArray.count;
                dispatch_resume(_gcd_timer); //开启定时器
            });
            
        });
        
    }else{
        if(_didLoadHistoryMsgs == _firstInpageRecordMsgs){
            [SVProgressHUD showInfoWithStatus:@"没有历史记录了"];
            [_tableView.mj_header endRefreshing];
            return;
        }
        
        dispatch_suspend(_gcd_timer);
        
        
        
        //先找到数组中最旧的元素 的索引
        LBChatDetailCellModel *model = _dataSource[0];
        NSInteger targetIndex = model.indexInAllMsgs;
        
        __block NSMutableArray *resultArray = [NSMutableArray array];
        
        //去本地历史中加载
        [self loadHistoryWithIndex:targetIndex array:&resultArray];
        
        if(resultArray.count){
            NSInteger k = [resultArray.lastObject[@"indexrow"] integerValue];
            NSInteger m = [resultArray.firstObject[@"indexrow"] integerValue];
            if((k - m) == _offset){ //找到20条数据 就加入到数组中
                [self ecodeServerDataWithArray:resultArray beginIndex:-1 encodeType:EncodeTypeLocal];
                
                
                _didLoadHistoryMsgs += resultArray.count;
                [self.tableView.mj_header endRefreshing];
                dispatch_resume(_gcd_timer); //重启定时器
            }else{
                [resultArray removeAllObjects];
                _page_now ++;
                dispatch_async(_request_last_msg_queue, ^{
                    [self requestMsgsArray:&resultArray page:_page_now offset:_offset];
                    
                    //回主线程处理 更新UI
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(resultArray.count){
                            [self ecodeServerDataWithArray:resultArray beginIndex:targetIndex encodeType:EncodeTypeServer];
                            
                            [self.tableView reloadData];
                            
                            //将20条数据存储到数据库中
                            [self saveMsgs:_dataSource];
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"没有请求到数据"];
                        }
                        
                        _didLoadHistoryMsgs += resultArray.count;
                        [self.tableView.mj_header endRefreshing];
                        dispatch_resume(_gcd_timer); //重启定时器
                    });
                });
            }
            
        }else{
            [resultArray removeAllObjects];
            _page_now ++;
            dispatch_async(_request_last_msg_queue, ^{
                [self requestMsgsArray:&resultArray page:_page_now offset:_offset];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(resultArray.count){
                        //没从本地拿到
                        [self ecodeServerDataWithArray:resultArray beginIndex:targetIndex encodeType:EncodeTypeServer];
                        
                        [self.tableView reloadData];
                        
                        //将20条数据存储到数据库中   //[self findLastNewMsgInHistoryDBIndexWithModel:_dataSource[0]];
                        [self saveMsgs:_dataSource];
                    }else{
                        [SVProgressHUD showErrorWithStatus:@"没有请求到数据"];
                    }
                    
                    _didLoadHistoryMsgs += resultArray.count;
                    [self.tableView.mj_header endRefreshing];
                    dispatch_resume(_gcd_timer); //重启定时器
                });
            });
        }
    }
}


#pragma mark ---  去本地拿历史数据
- (void)loadHistoryWithIndex:(NSInteger)targetIndex array:(NSMutableArray **)resultArray{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where indexrow between %zd and %zd order by indexrow desc",self._t_name,targetIndex - 1, targetIndex - _offset];
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(_db_chat_local_history, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            const unsigned char *time  = sqlite3_column_text(stmt, 1);
            const unsigned char *icon  = sqlite3_column_text(stmt, 0);
            const unsigned char *ID    = sqlite3_column_text(stmt, 2);
            const unsigned char *memID = sqlite3_column_text(stmt, 3);
            const unsigned char *name  = sqlite3_column_text(stmt, 4);
            const unsigned char *msg   = sqlite3_column_text(stmt, 5);
            int index   = sqlite3_column_int(stmt, 6);
            @autoreleasepool {
                NSDictionary *dic = @{
                                      @"createTime":[@"" initWithUTF8String:(const char*)time],
                                      @"headImg":[@"" initWithUTF8String:(const char*)icon],
                                      @"id":[@"" initWithUTF8String:(const char*)ID],
                                      @"memberId":[@"" initWithUTF8String:(const char*)memID],
                                      @"memberNickname":[@"" initWithUTF8String:(const char*)name],
                                      @"msg":[@"" initWithUTF8String:(const char*)msg],
                                      @"indexrow":@(index)
                                      };
                [*resultArray addObject:dic];
            }
        }
    }
}


#pragma mark ---  解析数据
- (void)ecodeServerDataWithArray:(NSArray *)array beginIndex:(NSInteger)beginIndex encodeType:(EncodeType)type{
    @synchronized (self) {
        for (NSInteger k = array.count -1; k>=0; k--) {
            @autoreleasepool {
                NSDictionary *dic = array[k];
                LBChatDetailCellModel *model = [LBChatDetailCellModel modelWithDic:dic];
                if(type == EncodeTypeServer){//服务器的 要算
                    model.indexInAllMsgs = beginIndex - k; //是所有记录中的哪一条
                }else{//本地的
                    model.indexInAllMsgs = [dic[@"indexrow"] integerValue];
                }
               
                [self.dataSource addObject:model];
            }
        }
    }
    
}

#pragma mark --- 模拟服务器请求数据
- (void)requestMsgsArray:(NSMutableArray **)resultArray page:(NSInteger)page offset:(NSInteger)offset{
    NSString *sql = [NSString stringWithFormat:@"select * from t_chat limit %zd,%zd",page * offset,offset];
    
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(_db_chat_server, sql.UTF8String, -1, &stmt, NULL);
    
    if(result == SQLITE_OK){
        
        //拿到服务器返回的总数
        _allMsgs = [[_serverTotalsDic objectForKey:keyTotals] integerValue];
        
        if(_isfirstInChatPage){
            _firstInpageRecordMsgs = _allMsgs;
        }
        
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
                [*resultArray addObject:dic];
            }
        }
        
        
    }
}




/** 找到要存储的目标位置*/
- (void)findLastNewMsgInHistoryDBIndexWithModel:(LBChatDetailCellModel *)model{
    //insert OR IGNORE into fdsfa(dgh) values(4);
    
}

/** 插入记录到数据库*/
- (void)saveMsgs:(NSArray<LBChatDetailCellModel *> *)array{
    //insert OR IGNORE into fdsfa(dgh) values(4);
    NSMutableString *sql = [[NSString stringWithFormat:@"insert OR IGNORE into %@(headImg,createTime,id,memberID,memberNickName,msg,indexrow) values",self._t_name] mutableCopy];
    for (NSInteger k = 0; k < array.count; k++) {
        @autoreleasepool {
            LBChatDetailCellModel *model = array[k];
            NSString *str = [NSString stringWithFormat:@"('%@','%ld','%zd','%zd','%@','%@',%zd),",model.iconUrl,model.time,model.friendID,model.friendID,model.nickName,model.content,model.indexInAllMsgs];
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
