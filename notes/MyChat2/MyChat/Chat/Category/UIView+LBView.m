//
//  UIView+LBView.m
//  MyChat
//
//  Created by   LiuBo on 2017/9/8.
//  Copyright © 2017年 LiuBo. All rights reserved.
//

#import "UIView+LBView.h"
#import <objc/runtime.h>


typedef NS_ENUM(NSUInteger, BlockType){
    BlockTypeCGRect,
    BlockTypeCGFloat,
    BlockTypeCGPoint
};

@implementation UIView (LBView)
BasicProperty
- (CGFloat)x    {    return self.frame.origin.x;        }

- (CGFloat)y    {    return self.frame.origin.y;        }

- (CGFloat)w    {    return self.frame.size.width;      }

- (CGFloat)h    {    return self.frame.size.height;     }

- (CGFloat)c_x  {    return self.center.x;              }

- (CGFloat)c_y  {    return self.center.y;              }

- (CGSize)size  {    return self.frame.size;            }

- (CGFloat)m_x  {    return CGRectGetMaxX(self.frame);  }

- (CGFloat)m_y  {    return CGRectGetMaxY(self.frame);  }




#define setter
- (void)setX:(CGFloat)x{
    CGRect rect = self.frame;
    rect.origin.x = x;
    self.frame = rect;
}

- (void)setY:(CGFloat)y{
    CGRect rect = self.frame;
    rect.origin.y = y;
    self.frame = rect;
}


- (void)setW:(CGFloat)w{
    CGRect rect = self.frame;
    rect.size.width = w;
    self.frame = rect;
}

- (void)setH:(CGFloat)h{
    CGRect rect = self.frame;
    rect.size.height = h;
    self.frame = rect;
}



- (void)setC_x:(CGFloat)c_x{
    CGPoint center = self.center;
    center.x = c_x;
    self.center = center;
}

- (void)setC_y:(CGFloat)c_y{
    CGPoint center = self.center;
    center.x = c_y;
    self.center = center;
}


#pragma mark *************** rutime
static const void *objc_view_new_instance_identifyID = &objc_view_new_instance_identifyID;

- (NSString *)identifyID{
    return [[dic objectForKey:objc_getAssociatedObject(self, objc_view_new_instance_identifyID)] lastObject];
}



#pragma mark -- 链式
+ (instancetype)createView:(void (^)(__kindof UIView *view))viewMaker{
    UIView *view = [[self alloc] init];
    viewMaker(view);
    return view;
}

- (__kindof UIView * (^)(CGRect value))init_frame{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGRect value) = ^(CGRect value){
        weak_self.frame = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_x{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.x = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_y{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.y = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_w{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.w = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_h{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.h = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGPoint value))init_c{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGPoint value) = ^(CGPoint value){
        weak_self.center = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_c_x{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.c_x = value;
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(CGFloat value))init_c_y{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(CGFloat value) = ^(CGFloat value){
        weak_self.c_y = value;
        return weak_self;
    };
    return block;
}

static NSMutableDictionary *dic;
- (__kindof UIView * (^)(NSString *value))init_identify{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(NSString *value) = ^(NSString *value){
        if(self.identifyID)return weak_self;
        
        NSString *hashStr = [NSString stringWithFormat:@"%zd",self.hash];
        [dic setObject:@[weak_self,value] forKey:hashStr];
        
        objc_setAssociatedObject(self, objc_view_new_instance_identifyID, hashStr, OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        return weak_self;
    };
    return block;
}

- (__kindof UIView * (^)(UIColor *))init_bgColor{
    __weak typeof(self) weak_self = self;
    UIView *(^block)(UIColor *value) = ^(UIColor *value){
        weak_self.backgroundColor = value;
        return weak_self;
    };
    return block;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    @try {
        if([key isEqualToString:@"_identify"] || [key isEqualToString:@"identify"])
        @throw [NSException exceptionWithName:@"KVC出错" reason:@"没找到这个key" userInfo:nil];
        
        [super setValue:value forKey:key];
    } @catch (NSException *exception) {
        NSLog(@"出现异常:%@  原因:%@",exception.name,exception.reason);
    } @finally {
        
    }
   
}

+ (__kindof UIView *)viewWithIdentify:(NSString * const)identify{
    return [[dic objectForKey:objc_getAssociatedObject(self, objc_view_new_instance_identifyID)] firstObject];
}


#pragma mark *************** system
+ (void)load{
    dic = [NSMutableDictionary dictionary];
}



#pragma mark *************** public method(有的是辅助)
+ (instancetype)roundViewWithRadius:(CGFloat)radius bgColor:(UIColor *)bgColor rect:(CGRect)rect{
    UIView *view = [[self alloc] initWithFrame:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = [view creatRoundedRectForRect:rect radius:radius];
    
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    return view;
}

- (CGMutablePathRef)creatRoundedRectForRect:(CGRect)rect radius:(CGFloat)radius {
    //申请路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    //将起始点移动到点0
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    //绘制曲线1
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    //绘制曲线2
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    //绘制曲线3
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    //绘制曲线4
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    //闭合path，绘制直线5
    CGPathCloseSubpath(path);
    
    return path;
}


@end
