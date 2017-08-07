# 数据库的简单使用
##使用步骤 
###导入框架 <sqlite3.h>

### 打开数据库

```objc
#import "ViewController.h"
#import <sqlite3.h>
@interface ViewController ()
/** 数据库*/
@property(nonatomic,assign) sqlite3 *db;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *dbPath = [path stringByAppendingPathComponent:@"db.sqlite"];
    
    
    //打开数据库
    int result = sqlite3_open(dbPath.UTF8String, &_db);
    if (result == SQLITE_OK) {
        NSLog(@"打开成功");
        
        //创建表
        [self createTable];
    }else{
        NSLog(@"打开失败");
    }
}
int func(void *m, int a, char **b, char **c){
    NSLog(@"%d,%s,%s",a,*b,*c);
    return a;
}

typedef int (*Callback)(void *, int, char **, char **);
Callback calls = func;
- (void)createTable{
    NSString *sql = @"create table if not exists t_person (id integer primary key autoincrement,name text not null, age integer not null default 12)";
    
    void *s = NULL;
    int c = 10;
    char *b = NULL;
    
    char *d = NULL;
    char *errmsg;
    
    int result = sqlite3_exec(_db, sql.UTF8String, calls(s,c,&b,&d), NULL, &errmsg);
    if(result == SQLITE_OK){
        NSLog(@"执行成功");
    }else{
        NSLog(@"执行失败 %s",errmsg);
    }
    
}
- (IBAction)insert:(id)sender {
    char *errmsg;
    NSString *sql = @"insert into t_person (name,age) values('张璐',25);";
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if(result == SQLITE_OK){
        NSLog(@"执行成功");
    }else{
        NSLog(@"执行失败");
    }
}

- (IBAction)delete:(id)sender {
    char *errmsg;
    NSString *sql = @"delete from t_person where name='张璐';";
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if(result == SQLITE_OK){
        NSLog(@"执行成功");
    }else{
        NSLog(@"执行失败");
    }
}
- (IBAction)update:(id)sender {
    char *errmsg;
    NSString *sql = @"update t_person set name = '布兰妮' where name='张璐';";
    int result = sqlite3_exec(_db, sql.UTF8String, NULL, NULL, &errmsg);
    if(result == SQLITE_OK){
        NSLog(@"执行成功");
    }else{
        NSLog(@"执行失败");
    }
}
- (IBAction)select:(id)sender {
    //准备查询
    NSString *sql = @"select * from t_person";
    /*
     参数3 sql语句的字节数  给 -1 表示自动去计算
     参数4 句柄  表示查询结果的指针, 通过这个句柄一次一次取 记录
     */
    sqlite3_stmt *stmt;
    int result = sqlite3_prepare_v2(_db, sql.UTF8String, -1, &stmt, NULL);
    if (result == SQLITE_OK) {
        NSLog(@"准备成功");
        //取记录
        while(sqlite3_step(stmt) == SQLITE_ROW){
            
            //字符串一定要对应 text 并且字段名也要对应 这里的 name 在 表中要 第1个 字段
            char *name = sqlite3_column_text(stmt, 1);
            
            //字段 age 在表中 第2个 位置 并且是 int类型, 这里要用 int
            int age = sqlite3_column_int(stmt, 2);
            printf("%s %d",name,age);
        }
    }
    
    
}

@end
```


# 后面有时间自己封装