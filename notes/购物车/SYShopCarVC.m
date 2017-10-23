//
//  SYShopCarVC.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/19.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYShopCarVC.h"
#import "SYShopCarCell.h"
#import "SYShopCarVCToolBar.h"

@interface SYShopCarVC ()<UITableViewDelegate,UITableViewDataSource>
{
    UILabel *_navTitleLab;
}
/** 表格 table */
@property (nonatomic,weak) UITableView *table;

/** 脚步的 toolbar */
@property (nonatomic,strong) SYShopCarVCToolBar *myToolBar;
@end





#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-unsafe-retained-assign"


static SYShopCarVC *_shopCarVC;
@implementation SYShopCarVC

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shopCarVC = [[self alloc] init];
    });
    return _shopCarVC;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shopCarVC = [super allocWithZone:zone];
    });
    return _shopCarVC;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

#warning 判断更新购物车
    
}

#pragma mark --- 释放资源
- (void)dealloc{
    free(ShopCarMGR->_selectGoodArray);
    ShopCarMGR->_selectGoodArray = NULL;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.table reloadData];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    Observer(self, @"弹出删除商品", @selector(deleteGoodsAction:), nil);
    Observer(self, @"更新数据成功,重新请求数据刷新", @selector(resetData), nil);
    [self setUPUI];
    
    //请求商品列表
    [self requesGoodsList];
    
}



#pragma mark --- 重新请求数据
- (void)resetData{
    [self requesGoodsList];
}


#pragma mark --- 接收到通知 打开商品删除和取消的提示框
- (void)deleteGoodsAction:(NSNotification *)noti{
   
    UIAlertController *vc = noti.object;
    
    [self presentViewController:vc animated:YES completion:nil];
}



#warning --- 商品的价格 没用到这个接口
- (void)requestAllGoodsTotalsPrice{
    [[SYRequest shareRquest] syRequestWithURL:r_goods_car_price_num Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,nil) sucessBlock:^(id obj) {
        if(r_obj()){
            XYLog(@"%@",r_obj_dic);
        }else{
            XYLog(@"%@",r_obj_msg());
        }
    } failBlock:^(id obj) {
        
    }];
}


#pragma mark --- 解析数据
- (void)decodeData:(NSDictionary *)dic{
    NSArray *array = dic[@"vos"];
    NSInteger i = 0;
    for (NSDictionary *dics in array) {
        ShopCarGoodsCellModel *model = [ShopCarGoodsCellModel modleWithDic:dics];
        model.indexInArray = i++;
        NSLog(@"%@",model.goodsSpecId);
        [shopMgrArray addObject:model];
    }
    
    ShopCarMGR->_selectGoodArray = NULL;
    ShopCarMGR->_selectGoodArray = calloc(0, sizeof(int) * i * 2);
}



#pragma mark --- 请求商品数据
- (void)requesGoodsList{
    [SVProgressHUD showWithStatus:@"请求商品列表"];
    [[SYRequest shareRquest] syRequestWithURL:r_goods_car_list Args:R_Param(timeStapStr,TimeStamp,r_token_key,kRequesttoken,nil) sucessBlock:^(id obj) {
        [SVProgressHUD dismiss];
        if(r_obj()){
            [self decodeData:r_obj_dic];
            [self.table reloadData];
        }else{
            [self showNsstringMessageInWindow:r_obj_msg()];
        }
    } failBlock:^(id obj) {
        [SVProgressHUD dismiss];
    }];
}



#pragma mark --- 编辑/购物模式切换
- (void)editBtnClick:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    if(btn.isSelected){
        ShopCarMGR.modeStyle = kShopModeStyleEdit;
    }else{
        ShopCarMGR.modeStyle = kShopModeStyleShopping;
    }
}



#pragma mark --- UI
- (void)setUPUI{
    self.view.backgroundColor = COLOR(d6d6d6);
    
    
    if(self.navigationController.navigationBarHidden){
        self.navigationController.navigationBarHidden = NO;
    }
    self.navigationItem.titleView = _navTitleLab = [UINavigationItem titleViewForTitle:@"购物车"];
    
    UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitle:@"完成" forState:UIControlStateSelected];
    [editBtn setTitleColor:COLOR(000000) forState:UIControlStateNormal];
    editBtn.w = 40;
    editBtn.h = 44;
    [editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    
    
    _table = ({
        UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        table.rowHeight = (168 + 28) / 2;
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.h = self.view.h - 64 - self.navigationController.toolbar.h;
        table.delegate = self;
        table.dataSource = self;
        table.showsVerticalScrollIndicator = table.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:table];
        ShopCarMGR.globalTable = table;
        table;
    });
    
    
    [self.view addSubview:self.myToolBar];
    
}





#pragma mark --- 表格的代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return shopMgrArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SYShopCarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shopCarCell"];
    if (!cell) {
        cell = [[SYShopCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"shopCarCell"];
    }
    cell.model = shopMgrArray[indexPath.row];
    return cell;
}




#pragma mark --- tool bar
- (SYShopCarVCToolBar *)myToolBar{
    if(!_myToolBar){
        _myToolBar = [[SYShopCarVCToolBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - self.navigationController.toolbar.h - 64, self.view.w, self.navigationController.toolbar.h)];
        ShopCarMGR.globalToolBar = _myToolBar;
     }
    return _myToolBar;
}

@end

#pragma clang diagnostic pop
