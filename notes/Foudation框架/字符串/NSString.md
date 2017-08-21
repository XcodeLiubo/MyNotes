# 不可变字符串 NSString

## NSString 介绍
* 创建字符串
	- 类方法
	- 实例方法
	- @""
	- NSBoundle 路劲沙河文件获取
	- 网络URL
* 常用功能
	- 写入文件或者URL
	- 获取字符串长度, 包括总长度, 总字节数
	- 获取字符串中的单个字符或字节, 也可指定位置, 指定范围获取
	- 获取 C 字符串
	- 连接字符串
	- 分隔字符串
	- 替换字符串
	- 比较字符串
	- 大小转换等

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
#warning 创建
        {
            // 用 unicode 初始化 字符串
            unichar data[] = {97,98,99,100};
            
            NSString *str = [[NSString alloc] initWithCharacters:data length:sizeof(data)/sizeof(char)];
            NSLog(@"%@",str);
        }
        
        {
            // 通过 C 字符串来初始化
            char *cstr  = "hello meinv";
            NSString *str = [[NSString alloc] initWithUTF8String:cstr];
            
        }
        
        
        {
            
            
            // 将字符串写入到文件中
            NSString *str = @"nihao";
            
            [str writeToFile:nil atomically:yearMask encoding:NSUTF8StringEncoding error:nil];
        }
        
        {
            // 从文件中读取字符串
            NSString *str = [NSString stringWithContentsOfFile:nil encoding:NSUTF8StringEncoding error:nil];
        
        }
        
#warning 功能
        {
            // 追加字符串
            NSString *str = @"我爱";
            str = [str stringByAppendingString:@"你"];
            // str == @"我爱你" // 但是地址变了
            
            str = [str stringByAppendingFormat:@"%s",", 是真的!"];
            // str == "我爱你, 是真的!" // 地址又变新的了
        }
        
        
        {
            // 转换成C的字符串
            NSString *str = @"wo ai ni";
            const char *s = [str UTF8String];
            
        }
        
        {
            // 获取字符串
            NSString *str = @"wo ai ni, shi zhe de, ni xiang xin ma?";
            NSUInteger length = str.length; // 长度 字符个数
            NSUInteger byteLength = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding]; // 按 UT8 解码后的字节数
            
            // 从第5个开始后面的字符串
            NSString *resultStr = [str substringFromIndex:2];
            
            // 前 10个字符串
            resultStr = [str substringToIndex:10];
            
            
            // 3 ~ 10 的字符串
            resultStr = [str substringWithRange:NSMakeRange(3, 10)];
            
            // 获取位置
            NSRange range = [str rangeOfString:@"ai ni"];
            
            //转换成大写
            resultStr = [resultStr uppercaseString];
        }
        
        
/* *******************************  NSMutableString  *************************************************************** */
        
        NSString *st = @"wo ai ni, shi zhen de!";
        {
            NSMutableString *str = [st mutableCopy];
            [str appendString:@"\ngun!"];
        
        }
        
        {
            NSMutableString *str = [NSMutableString string];
            [str appendString:@"nihao"];
        }
        
        
        {
            NSMutableString *str = [NSMutableString string];
            [str appendString:@"nihao"];
            [str insertString:@" bu " atIndex:2];
        
        }
        
        
        {
            NSMutableString *str = [NSMutableString string];
            [str appendString:@"nihao"];
            [str deleteCharactersInRange:NSMakeRange(1, 2)];
            
        }
    }
    return 0;
}


```