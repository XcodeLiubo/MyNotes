# MapKit

### MapKit 框架使用前提
* 导入框架 
	- 必须在项目中手动导入 **框架 MapKt.framework** 不是头文件
* 导入主头文件 \<MapKit/MapKit.h\>

### Mapkit框架使用须知
* MapKit框架中所有数据类型的前缀都是 MK
* MapKit有一个比较重要的 UI 控件 : **MKMapView**, 用于地图显示


### 地图的类型 (通过设置MKMapView的mapType 可以设置地图类型)
*          MKMapTypeStanded   普通地图
*        MKMapTypeSatellite	卫星地图
*           MKMapTypeHybird	混合模式
* MKMapTypeSatelliteFlyover	3D立体卫星(**iOS 9.0**)
* MKMapTypeHybirdFlyover		3D立体混合(**iOS 9.0**)


## 属性
### 代理(**MKMapViewDelegate**)
* delegate
	- 大头针移动 区域变化 等待地图上显示的信息通过通知回调

### 基本
* mapType 地图类型
* region 	区域
	- 可以修改区域以适应视图使用区域匹配的方面比率
* centerCoordinate 
	- 中心坐标允许在不改变缩放水平的情况下改变该区域的坐标
* visibleMapRect
	- 在投影坐标中存取地图的可见区域

### 交互
* zoomEnabled
	- 是否允许缩放
* scrollEnabled
	- 是否允许滑动
* rotateEnabled (**ios7**)
	- 是否允许旋转
* pitchEnabled  (**ios7**)


### 显示工具(**BOOL**)
* showsCompass (**iOS 9.0**)
	- 指南针
* showsScale 	(**iOS 9.0**)	
	- 比例尺
* showsPointsOfInterest (**iOS 7.0**)
	- 显示当前视图中 用户感兴趣的 坐标
* showsBuildings (**iOS 7.0**)
	- 显示建筑 
* showsTraffic	(**iOS 9.0**)
	- 交通
* showsUserLocation
	- 用户位置 必须用 CLLocationManager 去定位(CoreLocation的定位使用)
* userLocationVisible
	- 如果用户的位置显示在当前可见的地图区域内，则返回YES 

### 状态
* userLocation(**MKUserLocation**) 
	- 表示用户位置的注释
* userTrackingMode(**MKUserTrackingMode**)
	- 用户轨迹模式, 打开地图后, 怎么显示
	- MKUserTrackingModeFollow 跟踪
	- MKUserTrackingModeFollowWithHeading 跟踪并且移动
* annotationVisibleRect(**Rect**)
	- 当注释的视图是当前显示的时候,是可用的 Rect
	- 当代理动画添加视图时用到这个属性  




## MapKit的基本使用
### 创建 (可以在 stroyboard中拖控件, 也可以代码)
```objc
self.mapView.mapType = MKMapTypeStandard;
    
    //显示比例尺
//    self.mapView.showsScale = YES;
    
    //显示指南针
//    self.mapView.showsCompass = YES;
    
    //显示 showsBuildings showsTraffic
    
    //显示用户当前的地理位置  必须 CLLocationManager 定位
    [self mgr];
    self.mapView.showsUserLocation = YES;
    
    //自动定位到用户当前的位置 (效果像百度地图打开时主动定位到用户当前的位置一样)
    self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;



- (CLLocationManager *)mgr{
    if (!_mgr){
        self->_mgr = [[CLLocationManager alloc] init];
        _mgr.delegate = self;
        if ([_mgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_mgr requestWhenInUseAuthorization];
            
            if([_mgr respondsToSelector:@selector(allowsBackgroundLocationUpdates)]){
                [_mgr allowsBackgroundLocationUpdates];
            }
        }
        _mgr.distanceFilter = 10;
        _mgr.desiredAccuracy = kCLLocationAccuracyBest;
        [_mgr startUpdatingLocation];
    }
    return self->_mgr;
}



- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if(locations){
        NSLog(@"%@",[locations lastObject]);
    }
}

```
![](1.gif)



</br>
</br>
</br>
## MapKit高级用法
```objc
- (CLLocationManager *)mgr{
    if (!_mgr){
        self.mapView.mapType = MKMapTypeStandard;
        //self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        
        
        self->_mgr = [[CLLocationManager alloc] init];
        _mgr.delegate = self;
        if ([_mgr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_mgr requestWhenInUseAuthorization];
            if ([_mgr respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
                [_mgr allowsBackgroundLocationUpdates];
            }
            
        }
        _mgr.distanceFilter = 10;
        _mgr.desiredAccuracy = kCLLocationAccuracyBest;
        [_mgr startUpdatingLocation];
    }
    return self->_mgr;
}


#pragma mark *************** CLLocationManagerDelegate
/** 不同于下面的代理方法*/
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    NSLog(@"%@",[locations lastObject]);
}


#pragma mark *************** MKMapViewDelegate
/** 当大头针 在地图上移动 的时候会调用这个方法, 注意和 上面的方法的区别*/
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    /*
        MKUserLocation : 大头针模型  对应当前的位置
     */
    userLocation.title = @"liub";
    userLocation.subtitle = @"哥在此";
    
    /*
        设置地图的显示中心,会自动定位到用户的位置, 但不会放大,只有自己手动这么大
        设置了这个属性 不用再设置 用户的跟踪模式
     */
    [self.mapView setCenterCoordinate:userLocation.coordinate] ;
    
    
    //设置地图显示区域
    //MKCoordinateRegion region;
    //self.mapView setRegion:<#(MKCoordinateRegion)#>
}

```
###### PS: 上面代码的效果图
![](2.gif)


###### 如果用 region
```objc
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    /*
        MKUserLocation : 大头针模型  对应当前的位置
     */
    userLocation.title = @"liub";
    userLocation.subtitle = @"哥在此";
    
    /*
        设置地图的显示中心,会自动定位到用户的位置, 但不会放大,只有自己手动放大
        设置了这个属性 不用再设置 用户的跟踪模式
     */
    [self.mapView setCenterCoordinate:userLocation.coordinate] ;
    
    
    //设置地图显示区域
    /** 经纬度*/
    CLLocationCoordinate2D coordinate = userLocation.coordinate;
    /**
     跨度 经度: 0 ~ 360  纬度: 0 ~ 180
     为了方便 这里的 经纬度跨度 是根据下面的代理方法 直接 copy 来的,
     
     */
    MKCoordinateSpan span = MKCoordinateSpanMake(0.004023, 0.005515);
    MKCoordinateRegion region;
    region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:region];
}


/** 当 区域改变了就会调用这个代理方法, 在这里获取经纬度的跨度 传入到上面的代理方法中*/
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"纬度跨度:%f ,经度跨度:%f",mapView.region.span.longitudeDelta,mapView.region.span.latitudeDelta);
}
```

![](3.gif)




</br>
</br>
</br>

## 大头针
### 什么是大头针
* 用来标识位置有特定的东西
* iOS 如果要添加一个大头针, 只需要添加一个大头针的模型数据就可以了, 系统会自动加到视图上去
	- 这个数据模型是 MKUserLocation 这个模型遵守了 MKAnnotation 协议 
	- 调用方法 
		
		```objc
		//添加多个大头针模型
		self.mapView addAnnotations:(nonnull NSArray<id<MKAnnotation>> *)
		
		//添加单个大头针模型 
		self.mapView addAnnotation:(nonnull id<MKAnnotation>)
		```
	- 添加的 MKAnnotation 对象必须遵守  MKAnnotation 协议
	- 添加大头针 (系统的这个数据模型很多属性都是只读的, 只能添加个标题和子标题)
		
		```objc
		//添加一个大头针的数据模型
    	MKUserLocation *location = [[MKUserLocation alloc] init];
    
    	//设置大头针属性
    	location.title = @"yeye";
    	location.subtitle = @"zaici";
    
    	//添加到 mapView 上面
    	[self.mapView addAnnotation:location];

		
		```
		###### PS: 从上面的添加方法中可以看出, 要添加的模型必须是遵循了 MKAnnotation 的协议的对象, 而不是 MKUserLocation 这样系统的类, 换句话说 要自定义大头针的话, 必须遵循 MKAnnotation  而不用去继承 MKUserLocation
	- 自定义大头针
		
		```objc
		@interface MYLocation : NSObject<MKAnnotation>
			/** 必须要实现的*/
			@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
			/** 标题*/
			@property (nonatomic, copy, nullable) NSString *title;
			/** 子标题*/
			@property (nonatomic, copy, nullable) NSString *subtitle;
		@end
		
		- (void)viewDidLoad{
			MYLocation *myLocation = [[MYLocation alloc] init];
    		
    		//要显示的位置
    		myLocation.coordinate = self.mapView.centerCoordinate;
    		
    		//只要执行了这句话后, 就会调用 下面这个代理方法, 要求返回一个 大头针的视图
    		[self.mapView addAnnotation:myLocation];
		} 
		
		
		/** 如果这个方法不实现或者返回 nil 系统会返回 MKUserLocation */
		- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:		(id<MKAnnotation>)annotation
		{
    
    		return [[MKAnnotationView alloc] initWithAnnotation:self.myLocation 					reuseIdentifier:@"one"];
		}
		
		```
	- 获取手指点击屏幕时, 在地图上的位置
		
		```objc
			- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent*)event{
    			UITouch *touch = [touches anyObject];
    			CGPoint p = [touch locationInView:self.mapView];
    
    			CLLocationCoordinate2D mapPoint = [self.mapView convertPoint:p toCoordinateFromView:self.mapView];
    
    
			}
		
		```
		
	- 移除大头针
	
		```objc
		NSArray *annotates = self.mapView.annotations;
    	[self.mapView removeAnnotations:annotates];
    	[self.mapView removeAnnotation:(nonnull id<MKAnnotation>)]
		```

</br>
</br>
</br>
## 系统的导航
```objc
@interface ViewController ()
/** 地理编码*/
@property(nonatomic,strong) CLGeocoder *geocoder;
@end

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self begin];
}
- (void)begin{
    self.geocoder = [[CLGeocoder alloc] init];
    __block CLPlacemark *clp1 = nil;
    __block CLPlacemark *clp2 = nil;
    [self.geocoder geocodeAddressString:@"武汉" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        clp1 = [placemarks firstObject];
        
        [self.geocoder geocodeAddressString:@"拉萨" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            clp2 = [placemarks firstObject];
            
            
            /**
             To create an MKPlacemark from a CLPlacemark, call [MKPlacemark initWithPlacemark:] passing the CLPlacemark instance that is returned by CLGeocoder.
             调用  [MKPlacemark initWithPlacemark:] 传一个由 CLGeocoder(地理编码)返回的 CLPlacemark 来创建 MKPlacemark
             */
            MKPlacemark *mkp1 = [[MKPlacemark alloc] initWithPlacemark:clp1];
            MKMapItem *item1 = [[MKMapItem alloc] initWithPlacemark:mkp1];
            
            MKPlacemark *mkp2 = [[MKPlacemark alloc] initWithPlacemark:clp2];
            MKMapItem *item2 = [[MKMapItem alloc] initWithPlacemark:mkp2];
            
            NSArray *items = @[item1,item2];
            NSDictionary *itemDic = @{
                                      MKLaunchOptionsMapTypeKey:@(MKMapTypeStandard),
                                      MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving
                                      };
            [MKMapItem openMapsWithItems:items launchOptions:itemDic];
            
            
            
            
            
            
            
        } ];
    }];
    
}

```
![](5.gif)



</br>
</br>
</br>
## 3D视角/地图截图
### 3D视角
```objc
/**
     3D视角
     参数1 : 看的目标点
     参数2 : 从哪个点看
     参数3 : 从多高看
     */
    CLLocationCoordinate2D targetPoint = {23.132931,113.1110891};
    CLLocationCoordinate2D beginPoint = {23.135931,113.1110890};
    self.mapView.camera = [MKMapCamera cameraLookingAtCenterCoordinate:targetPoint fromEyeCoordinate:beginPoint eyeAltitude:10];
```
![](4.gif)

### 地图截图 
```objc
/*
     地图截图
     
     */
    
    MKMapSnapshotOptions *option = [[MKMapSnapshotOptions alloc] init];
    
    option.region = self.mapView.region;
    option.showsBuildings = YES;
    option.scale = [UIScreen mainScreen].scale;
    
    MKMapSnapshotter *snap = [[MKMapSnapshotter alloc] initWithOptions:option];
    [snap startWithCompletionHandler:^(MKMapSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if(error){
            NSLog(@"错误");
        }
        //截出的图片
        UIImage *image = snapshot.image;
    }];

```


</br>
</br>
</br>

## 手绘路线
```objc

#import "ViewController.h"
#import <MapKit/MapKit.h>
@interface ViewController ()<MKMapViewDelegate>
/** 地图*/
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
/** 地理编码*/
@property(nonatomic,strong) CLGeocoder *coder;
@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.coder = [[CLGeocoder alloc] init];
    
    //用到的最重要的类 MKDirection 获取线路
    // Overlay 覆盖层 画路线的时候用
    
    
    [self.coder geocodeAddressString:@"上海" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *pl1 = [placemarks firstObject];
        
        
        [self.coder geocodeAddressString:@"武汉" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            //创建一个请求
            MKDirectionsRequest *mdrequest = [[MKDirectionsRequest alloc] init];
            
            //设置起点坐标
            
            CLPlacemark *pl2 = [placemarks firstObject];
            
            
            
            
            MKPlacemark *mkp1 = [[MKPlacemark alloc] initWithPlacemark:pl1];
            MKMapItem *mkitem1 = [[MKMapItem alloc] initWithPlacemark:mkp1];
            mdrequest.source = mkitem1;
            
            
            //设置终点坐标
            MKPlacemark *mkp2 = [[MKPlacemark alloc] initWithPlacemark:pl2];
            MKMapItem *mkitem2 = [[MKMapItem alloc] initWithPlacemark:mkp2];
            mdrequest.destination = mkitem2;
            
            
            MKDirections *direcs = [[MKDirections alloc] initWithRequest:mdrequest];
            
            //请求之后的回调
            [direcs calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
                
                
                /*
                 MKDirectionsResponse
                 routes 路线的数组
                 
                 
                 
                 MKRoute 
                 name: 路线名称
                 
                 distance: 路线的距离
                 
                 expectedTravelTiem: 预期时间
                 
                 polyline: 拆线(数据模型 里面都是坐标点)
                 
                 steps: <MKRouteStep>
                    instructions : 行走提示
                    notice 声音
                    ...
                 */
                
                
                
                //遍历获取线路
                [response.routes enumerateObjectsUsingBlock:^(MKRoute * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSLog(@"%@",obj.polyline);
                    /*
                     MKPolyline
                    是一个模型数据, 当调用 [self.mapView addOverlay:<#(nonnull id<MKOverlay>)#>]
                     会在代理方法中要求拿到 覆盖层的 view
                     */
                    //拿到 路线
                    MKPolyline *polyline = obj.polyline;
                    [self.mapView addOverlay:polyline];
                }];
            }];
            
        }];
    }];
}


/**
 当添加一个覆盖层的时候 会来到这里, 要求返回一个 图层给系统

 @param mapView 地图
 @param overlay 添加的覆盖层的模型, 是通过 addOverlay时传过来的
 @return 返回的是一个 渲染图层的模型
 */
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
    /*
        一个路线的模型对应一个渲染对象模型 这里是    polyline对应 MKPolylineRenderer
     
        如果画圆在话 这样对应    MKCircle : MKCircleRenderer
     
     */
    MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    
    
    //设置 render的 属性
    render.lineWidth = 2.f;
    render.strokeColor = [UIColor redColor];
    return render;
}


@end
```

![](6.gif)
