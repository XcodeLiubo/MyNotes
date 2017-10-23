//
//  SYGoodsSubCategoryModel.m
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import "SYGoodsSubCategoryModel.h"

@implementation SYGoodsSubCategoryModel
+ (instancetype)modelWithDic:(NSDictionary *)dic{
    SYGoodsSubCategoryModel *model = [[SYGoodsSubCategoryModel alloc] init];
    [model setValuesForKeysWithDictionary:dic];
    
    return model;
}
@end
