//
//  SYGoodsSubCategoryModel.h
//  newsyrinx
//
//  Created by Liubo on 2017/10/18.
//  Copyright © 2017年 希芸. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYGoodsSubCategoryModel : NSObject
+ (instancetype)modelWithDic:(NSDictionary *)dic;

/** 二级标题的名称 */
@property (nonatomic,copy) NSString *name;

/** 编码 */
@property (nonatomic,copy) NSString *code;



@end
