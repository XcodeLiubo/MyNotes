# 日期与时间
## NSDate
* NSDate代表日期与时间

```objc
#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        {
            // date 的时间就是创建的那一刻 系统的时间
            NSDate *date = [NSDate date];
        }
        
        {
            // 从现在开始 2s 后
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:2.f];
            
            
            
            // 从 1970.1.1 开始 100000s 后的时间
            NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSince1970:100000];
            
            
            // 从 date2 开始计时, 过 2s 的时间
            NSDate *date3 = [[NSDate alloc] initWithTimeInterval:2 sinceDate:date2];
            
            
            // 现在开始 前 10s 的时间
            NSDate *date4 = [NSDate dateWithTimeIntervalSinceNow:-10];
            
            
        }
        
        
        {
            //获取系统当前的 local
            NSLocale *lcoal = [NSLocale currentLocale];
            
            NSDate *date = [NSDate date];
            NSLog(@"%@",[date descriptionWithLocale:lcoal]);
            //xxx年xx月xx日 星期xx 中国标准时间 xx:xx:xx
        }
        
        {
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:2.f];
            
            NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSince1970:100000];
            
            // 获取两个 日期 较晚的那个
            NSDate *date3 = [date2 laterDate:date];
            
            
            //获取两个 日期 较早的那个
            NSDate *date4 = [date2 earlierDate:date];
        }
        
        {
            NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow:2.f];
            
            NSDate *date2 = [[NSDate alloc] initWithTimeIntervalSince1970:100000];
            
            //时间差
            [date timeIntervalSinceDate:date2];
        
        }
        
    }
    return 0;
}
```


## NSDateFormatter
### 概念
* 日期格式器

### 功能
* 完成 NSDate 与 NSString之间的转换

### 使用步骤
* 创建一个NSDateFormatter对象
* 调用 setDateStyle:  setTimeStyle: 设置格式
	- NSDateFormtterNoStyle  不显示日期,时间的风格
	- NSDateFormtterShortStyle 显示短的日期
	- NSDateFormtterMediumStyle 显示中等的日期
	- NSDateFormtterMLongtyle   显示长的日期
	- NSDateFormtterMFulltyle  显示完整的日期
	- 如果打算使用自己的格式模板, 调用 NSDateFormatter 的 setDateFormate
### NSDate转换 NSString
* 调用NSDateFormatter 的 stringFormDate

### NSString 转换 NSDate
* 调用 NSDateFormatter dateFromString




## NSCalendar
### 概念
* 处理 NSDate 的各个 日期部分


### 常用的方法
* (NSDateComponents *)components:fromDate: 从NSDate中提取 年,月,日,时,分,秒各字段的信息
* dateFromCommponents: (NSDateComponents *)comps: 使用comps对象包含的 年, 月, 日, 时, 分, 秒各时间 字段的信息来创建 NSDate

### NSDateComponents
* 年, 月, 日, 时, 分, 秒(year,month,day,hour,minute,second,week,weekday)的存取方法

### 获取 NSDate 的各个时间字段
* 创建 NSCalendar
* 调用 (NSDateComponents *)components:fromDate
* 调用 返回的 NSDateComponents * 对象的 各个时间的 getter

### 获取 NSDate 的各个时间字段
* 创建 NSCalendar
* 调用 (NSDateComponents *)components:fromDate
* 调用 返回的 NSDateComponents * 对象的 各个时间的 getter
  
### 从各个时间段 获取 NSDate
* 创建 NSCalendar
* dateFromCommponents: (NSDateComponents *)comps:
* 获取返回的 date