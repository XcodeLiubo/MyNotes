//
//  CommodityViewController.m
//  newsyrinx
//
//  Created by SPS on 2017/4/20.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "CommodityViewController.h"
#import "SYGoodsCell.h"
#import "SYGoodsCategoryCell.h"
#import "SYShopCarVC.h"

@interface CommodityViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSInteger _offset;
    NSInteger _requestStartPage;
    NSInteger _currenttitleIndex;   //当前选中的是 哪个title
    
    BOOL _isFirstInPage;            //是否第一次进来
}
/** 展示单个 商品的表格 */
@property (nonatomic,strong) UICollectionView *goodsCollection;

/** 商品的分类 导航 */
@property (nonatomic,strong) UICollectionView *categoryCollection;

/** 头部导航 */
@property (nonatomic,strong) UIView *headView;

/** 商品 数据源 */
@property (nonatomic,strong) NSMutableArray *goodsDataArray;

/** 商品 分类 */
@property (nonatomic,strong) NSMutableArray<GoodsCategoryModel *> *goodsCategoryArray;

/** key:当前选中的标题  value:当前标题下的商品 */
@property (nonatomic,strong) NSMutableDictionary *globalDic;

@end

@implementation CommodityViewController
- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _goodsCategoryArray = @[].mutableCopy;
    _goodsDataArray = @[].mutableCopy;
    _globalDic = @{}.mutableCopy;
    _isFirstInPage = YES;
    
    
    Observer(self, @"去购物车", @selector(goShopCarVC), nil);
    [self setUPUI];
}



- (void)goShopCarVC{
    SYShopCarVC *vc = [SYShopCarVC shareInstance];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark --- UI
- (void)setUPUI{
    UIImage *logoImg = IMAGE(LOGO);
    
    UIImageView *logoIMGView = [[UIImageView alloc] initWithImage:logoImg];
    logoIMGView.c_x = self.view.w * 0.5;
    logoIMGView.y = 20;
    [self.view addSubview:logoIMGView];
    nowH = logoIMGView.m_y;
   
    
    ShopCarBtn_instance.x = self.view.w - ShopCarBtn_instance.w - 10;
    ShopCarBtn_instance.c_y = logoIMGView.c_y;
    
    
    [self.view addSubview:ShopCarBtn_instance];
    
    //头部
    [self.view addSubview:self.headView];
    
    //商品列表
    [self.view addSubview:self.goodsCollection];
    
    //请求信息
    [self requesInfo];
}


#pragma mark --- 解析商品分类数据
- (void)decodeDatasourceWithSource:(NSArray *)obj{
    [obj enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GoodsCategoryModel *model = [GoodsCategoryModel modelWithDic:obj];
        model.index = idx;
        [self.goodsCategoryArray addObject:model];
    }];
}


#pragma mark --- 请求商品的分类
- (void)requesInfo{
    [SVProgressHUD show];
    [[SYRequest shareRquest] syRequestWithURL:r_goods_category Args:R_Param(timeStapStr,TimeStamp,nil) sucessBlock:^(id obj) {
        if (r_obj()) {
            [self decodeDatasourceWithSource:r_obj_dic[@"list"]];
            [self.categoryCollection reloadData];
            
            _currenttitleIndex = 0;  //第一次默认 第0个标题
            [self requestGoodsList];
        }else{
            [SVProgressHUD dismiss];
        }
    } failBlock:^(id obj) {
        [SVProgressHUD dismiss];
    }];
}



#pragma mark --- 请求商品列表
- (void)requestGoodsList{
    NSString *code = self.goodsCategoryArray[_currenttitleIndex].code;
    [[SYRequest shareRquest] syRequestWithURL:r_goods_list Args:R_Param(timeStapStr,TimeStamp,@"startNo",[NSString stringWithFormat:@"%zd",_requestStartPage],@"offset",[NSString stringWithFormat:@"%zd",_offset],@"code",code,nil) sucessBlock:^(id obj) {
        if(r_obj()){
            //NSNumber  [r_obj_dic[@"container"][@"totalNum"]
            [self decodeGoodsListWith:r_obj_dic[@"container"][@"list"]];
            [self.goodsCollection reloadData];
            [SVProgressHUD dismiss];
        }else{
            [SVProgressHUD dismiss];
        }
    } failBlock:^(id obj) {
        [SVProgressHUD dismiss];
    }];
}



#pragma mark --- 解析商品列表的数据成模型
- (void)decodeGoodsListWith:(NSArray *)obj{
    for (NSDictionary *dic in obj) {
        GoodsModel *model = [GoodsModel modelWithDic:dic];
        [self.goodsDataArray addObject:model];
    }
}



#pragma mark --- 网格
static CGFloat nowH;
static CGFloat goodsItem_w;
static CGFloat goodsItem_h;
- (UICollectionView *)goodsCollection{
    if(!_goodsCollection){
        
        CGFloat space = 5;
        goodsItem_w = (self.view.w - 3 * space)/2;
        goodsItem_h = goodsItem_w + 60;
        
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.minimumLineSpacing = space;
        flow.minimumInteritemSpacing = space;
        flow.sectionInset = UIEdgeInsetsMake(space, space, space, space);
        
        
        
        _goodsCollection = [[UICollectionView alloc] initWithFrame:(CGRect){0,nowH + 40,self.view.w,self.view.h - nowH - 49 - 40} collectionViewLayout:flow];
        
        _goodsCollection.delegate = self;
        _goodsCollection.dataSource = self;
        
        
        _goodsCollection.backgroundColor = CLEAR_COLOR;
        _goodsCollection.showsVerticalScrollIndicator = _goodsCollection.showsHorizontalScrollIndicator = NO;
        
        [_goodsCollection registerClass:[SYGoodsCell class] forCellWithReuseIdentifier:@"goodsCell"];
        
        
        //上拉刷新
        _goodsCollection.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_goodsCollection.mj_footer endRefreshing];
            });
        }];
        
        [self.view addSubview:_goodsCollection];
    }
    return _goodsCollection;
}



#pragma mark --- 头部导航
- (UIView *)headView{
    if(!_headView){
        _headView = [[UIView alloc] init];
        _headView.x = 0;
        _headView.y = nowH;
        _headView.w = self.view.w;
        _headView.h = 38;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = COLOR(dddddd);
        lineView.w = self.view.w;
        lineView.h = 1;
        lineView.c_x = _headView.w * 0.5;
        lineView.y = _headView.h - 1;
        [_headView addSubview:lineView];
        
        
        
        lineView = [[UIView alloc] init];
        lineView.backgroundColor = COLOR(dddddd);
        lineView.w = self.view.w;
        lineView.h = 1;
        lineView.c_x = _headView.w * 0.5;
        lineView.y = 0;
        [_headView addSubview:lineView];
        
        
        
        
        //商品的类别
        CGFloat space = 0;
        CGFloat item_w = 60;
        CGFloat item_h = 38;
        
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.minimumLineSpacing = space;
        flow.minimumInteritemSpacing = space;
        flow.sectionInset = UIEdgeInsetsMake(space, space, space, space);
        flow.itemSize = (CGSize){item_w,item_h};
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        
        _categoryCollection = [[UICollectionView alloc] initWithFrame:(CGRect){0,1,_headView.w,38} collectionViewLayout:flow];
        
        _categoryCollection.delegate = self;
        _categoryCollection.dataSource = self;
        _categoryCollection.bounces = NO;
        
        _categoryCollection.backgroundColor = CLEAR_COLOR;
        _categoryCollection.showsVerticalScrollIndicator = _categoryCollection.showsHorizontalScrollIndicator = NO;
        
        [_categoryCollection registerClass:[SYGoodsCategoryCell class] forCellWithReuseIdentifier:@"goodsCategoryCell"];
        
        [_headView addSubview:_categoryCollection];
        
        
        [self.view addSubview:_headView];

        
    }
    return _headView;
}



#pragma mark --- 表格的代理
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(collectionView == _goodsCollection) return _goodsDataArray.count;
    else return  _goodsCategoryArray.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == _goodsCollection){
        SYGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodsCell" forIndexPath:indexPath];
        cell.model = _goodsDataArray[indexPath.item];
        return cell;
    }else{
        SYGoodsCategoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"goodsCategoryCell" forIndexPath:indexPath];
        GoodsCategoryModel *model = _goodsCategoryArray[indexPath.item];
        if(_isFirstInPage && indexPath.row == 0){
            model.selected = YES;
            _isFirstInPage = NO;
        }
        cell.titleClick = ^(NSInteger idx){
            _currenttitleIndex = idx;
            [self.goodsDataArray removeAllObjects];
            [self requestGoodsList];
        };
        cell.model = model;
        return cell;
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(collectionView == _categoryCollection){ //标题的
        GoodsCategoryModel *model = _goodsCategoryArray[indexPath.item];
        return CGSizeMake(model.title_W, 38);
    }else{
        return (CGSize){goodsItem_w,goodsItem_h};
    }
}

@end
