# 数据存储
## iOS中数据存储的方式
* Plist(NSArray/NSDictionary..) 
	- 只能存储数组,字典 数组和字典里不能有自定义的对象
* Preference 偏好设置  
	- 也不能存储自定义对象
* 归档
	- 可以存储自定义对象, 但是是一次性做读取存储操作, 不容易拓展(更新数据)
* SQLite
	- 轻量级(占用的内存资源比较少) 操作方便, 速度快, 随意取一指定数量的数据
* Core Data


## SQLite
### 如何存储数据
* 以表的形式存储


### 数据库的操作步骤
* 创建数据库表 (表名, 一般以 **t_** 开头)
* 根据需要设计表结构 (字段 类型 主键等等)
* 插入记录 

### SQL语句 (不区分大小写)
#### DDL(**数据定义语句**)
* 包括 create drop
	- create table 创建表
	- drop table  删除表

#### DML (数据操作语句)
* 包括 insert update delete等操作
	- insert  插入新记录
	- update 更新记录
	- delete 删除记录

#### DQL(数据查询语句)
* 可以用于查询获得表中的数据
* 关键字 selecte 是 DQL(也是所有 SQL) 用得最多的操作
* 其他DQL常用的关键字有 where   order by   having
	
	
</br>
</br>
### 创建表
* **create table 表名 [字段1 字段类型1, 字段2 字段类型2, ....]**

```objc
create table t_student (id integer primary key autoincrement ,name text, age integer) 
```
* **create table if not exists 表名 [字段1 字段类型1, 字段2 字段类型2, ....]**
		
```objc
create table if not exists t_student (id integer primary key autoincrement ,name text, age integer) 
```



### 删除表
* **drop table 表名**

```objc
drop table t_student;
```
* **drop table if not exists 表名**

```objc
drop table if not exists t_student
```

</br>
</br>

### 插入记录
* insert into 表名 (字段1, 字段2, ...) values(值1,值2,...)

```objc
insert into t_student (name,age) values("小红",10);
```
</br>
</br>
### 更新记录
* update 表名 set 字段1 = value1, 字段2 = value2, ....  where 条件(字段N = valueN,....)

```objc

update t_student set name = "小美" where id = 1;
``` 

</br>
</br>
### 删除记录
* delete from 表名  where 条件(字段N = valueN,....)

```objc
delete from t_student where id = 1;
```
</br>
</br>
### 条件语句
* where 字段 ( =   is   !=    is not  >   and    or) 某个值

</br>
</br>


### DQL (select)
#### 普通查询
* select 字段1, 字段2,..... from 表名
* select * from 表名

#### 条件查询
* select * form 表名 [where 条件语句]

#### 排序查询
* select * form 表名 [条件语句] [order by 字段1 desc/asc, 字段2 desc/asc,....] 默认是升序

#### 数量查询
* select * from 表名 limit 数值1, 数值2
	- 跳过前面的 数值1, 然后取 数值2条 记录

</br>
</br>
### 简单约束
* not null   不能空
* unique     必须唯一
* default    指定字段的默认值

```objc
create table t_person (id integer primary key autoincrement, name text not null, age integer not null default 10)
```
</br>
</br>
### 外键约束
* 利用外键约束可以用来建立 表与表 之间的联系
* 外键的一般情况是: 一张表的某个字段, 引用着别一张表的 主键字段
* 新建一个外键 
	- 创建表的时候 直接定义外键
		- create table 表名_1(字段1 字段类型, 字段2 字段类型,... constraint 外键名 foregin key 字段_N references 表名_N([ 字段N ]))
			
			```objc
			create table t_person (id integer primary key autoincrement, age integer not null default 12, name text not null, class_id, constraint fk_person_id_class_id foreign key (id) references t_class(id) )
			```
	- 已经创建好的表 再加上 外键
		- alter table 外键表 add constraint 外键名 foreign key (要关联的字段) references 关联的表(一般主键字段)
</br>
</br>

### 连接查询
* 需要联合多张表才能查询数据

```objc
//给表 t_s 和 t_c 分别取了别名, 同时 用 . 连接了 s表对应的 name(别名sName), c表对应的 name(别名cName)
//这样的查询 是没有联系的
select s.name sName, c.name cName from t_s s ,t_c c


//改成这样
select s.name sName, c.name cName from t_s s ,t_c c where s.id = c.id;
```


</br>
</br>
</br>
</br>
</br>
</br>
</br>
</br>