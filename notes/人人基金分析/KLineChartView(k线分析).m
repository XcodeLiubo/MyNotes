//
//  TYBarChartView.m
//  CandlerstickCharts
//
//  k线图
//  Created by xdliu on 16/8/11.
//  Copyright © 2016年 liuxd. All rights reserved.
//

#import "KLineChartView.h"
#import "UIBezierPath+curved.h"
#import "KLineTipBoardView.h"
#import "MATipView.h"
#import "ACMacros.h"
#import "Global+Helper.h"
#import "VolumnView.h"
#import "KLineItem.h"

NSString *const KLineKeyStartUserInterfaceNotification = @"KLineKeyStartUserInterfaceNotification";
NSString *const KLineKeyEndOfUserInterfaceNotification = @"KLineKeyEndOfUserInterfaceNotification";

@interface KLineChartView ()

@property (nonatomic, assign) CGFloat yAxisHeight;

@property (nonatomic, assign) CGFloat xAxisWidth;

@property (nonatomic, strong) NSMutableArray<KLineItem *> *chartValues;

@property (nonatomic, assign) NSInteger startDrawIndex;

@property (nonatomic, assign) NSInteger kLineDrawNum;

@property (nonatomic, strong) KLineItem *highItem;

@property (nonatomic, assign) CGFloat maxHighValue;

@property (nonatomic, assign) CGFloat minLowValue;

//手势
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;

@property (nonatomic, assign) CGFloat lastPanScale;

//坐标轴
@property (nonatomic, strong) NSMutableDictionary *xAxisContext;

//十字线
@property (nonatomic, strong) UIView *verticalCrossLine;     //垂直十字线
@property (nonatomic, strong) UIView *horizontalCrossLine;   //水平十字线

@property (nonatomic, strong) UIView *barVerticalLine;

@property (nonatomic, strong) KLineTipBoardView *tipBoard;

@property (nonatomic, strong) MATipView * maTipView;

// 成交量图
@property (nonatomic, strong) VolumnView *volView;

//时间
@property (nonatomic, strong) UILabel *timeLbl;
//价格
@property (nonatomic, strong) UILabel *priceLbl;

//实时数据提示按钮
@property (nonatomic, strong) UIButton *realDataTipBtn;

//交互中， 默认NO
@property (nonatomic, assign) BOOL interactive;


@property(nonatomic,assign)BOOL show; //大盘曲线
@property(nonatomic,assign)NSInteger type;//类型


@end

@implementation KLineChartView

#pragma mark - life cycle

- (void)dealloc {
//    [self removeObserver];
}

- (id)init {
    if (self = [super init]) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup {
    self.fullScreen = YES;
    
    self.timeAxisHeight = 20.0;
    
    self.positiveLineColor = [UIColor colorWithRed:(31/255.0f) green:(185/255.0f) blue:(63.0f/255.0f) alpha:1.0];
    self.negativeLineColor = [UIColor colorWithRed:(232/255.0f) green:(50.0f/255.0f) blue:(52.0f/255.0f) alpha:1.0];
    
    self.upperShadowColor = self.positiveLineColor;
    self.lowerShadowColor = self.negativeLineColor;
    
    self.movingAvgLineWidth = 0.8;
    
    self.minMALineColor = HexRGB(0x019FFD);
    self.midMALineColor = HexRGB(0xFF9900);
    self.maxMALineColor = HexRGB(0xFF00FF);
    
    self.positiveVolColor = self.positiveLineColor;
    self.negativeVolColor =  self.negativeLineColor;
    
    self.axisShadowColor = [UIColor colorWithRed:223/255.0f green:223/255.0f blue:223/255.0f alpha:1.0];
    self.axisShadowWidth = 0.8;
    
    self.separatorColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0];
    self.separatorWidth = 0.5;
    
    self.yAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.yAxisTitleColor =  [Global convertHexToRGB:@"666666"];
//    [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.xAxisTitleFont = [UIFont systemFontOfSize:8.0];
    self.xAxisTitleColor =  [Global convertHexToRGB:@"666666"];
    //    [UIColor colorWithRed:(130/255.0f) green:(130/255.0f) blue:(130/255.0f) alpha:1.0];
    
    self.crossLineColor = HexRGB(0xC9C9C9);
    
    self.scrollEnable = YES;
    
    self.zoomEnable = YES;
    
    self.showAvgLine = YES;
    
    self.showBarChart = YES;
    
    self.yAxisTitleIsChange = YES;
    
    self.saveDecimalPlaces = 2;
    
    self.timeAndPriceTipsBackgroundColor = HexRGB(0xD70002);
    self.timeAndPriceTextColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    self.supportGesture = YES;
    
    self.maxKLineWidth = 10;
    self.minKLineWidth = 2;
    
    self.kLineWidth = 8.0;
    self.kLinePadding = 2.0;
    
    self.lastPanScale = 1.0;
    
    self.xAxisContext = [NSMutableDictionary new];
    
    self.numberOfMACount = 3;
    
    //添加手势
    [self addGestures];
    
    [self registerObserver];
}

/**
 *  添加手势
 */
- (void)addGestures {
    if (!self.supportGesture) {
        return;
    }
    
    [self addGestureRecognizer:self.tapGesture];
    
    [self addGestureRecognizer:self.panGesture];
    
    [self addGestureRecognizer:self.pinchGesture];
    
    [self addGestureRecognizer:self.longGesture];
}

/**
 *  通知
 */
- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTouchNotification) name:KLineKeyStartUserInterfaceNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endOfTouchNotification) name:KLineKeyEndOfUserInterfaceNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeObserver {
    [self removeObserver:self forKeyPath:KLineKeyStartUserInterfaceNotification];
    [self removeObserver:self forKeyPath:KLineKeyEndOfUserInterfaceNotification];
//    [self removeObserver:self forKeyPath:UIDeviceOrientationDidChangeNotification];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self hideTipsWithAnimated:NO];
    [_verticalCrossLine removeFromSuperview];
    _verticalCrossLine = nil;
    [_horizontalCrossLine removeFromSuperview];
    _horizontalCrossLine = nil;
    
    if (!self.chartValues || self.chartValues.count == 0) {
        return;
    }
    //x坐标轴长度
    self.xAxisWidth = rect.size.width - self.rightMargin - (self.fullScreen ? 0 : self.leftMargin);
    
    //y坐标轴高度
    self.yAxisHeight = rect.size.height - self.bottomMargin - self.topMargin;
    
    //坐标轴
    [self drawAxisInRect:rect];
    
    //时间轴
    [self drawTimeAxis];
    
    //k线
    [self drawKLine];
    
    //默认关闭大盘曲线
    if (!self.show) {
        [self drawMALine];
    }
    
    //y坐标标题
    [self drawYAxisTitle];
    
    //交易量
    [self drawVol];
}

#pragma mark - 开始调用画图方法

- (void)drawChartWithData:(NSArray *)data andShowBool:(BOOL)show  andType:(NSInteger)type{

    
    self.show = show;
    self.chartValues = [NSMutableArray arrayWithArray:data];


    if (self.showBarChart) {
        self.volView.data = data;
    }
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", self.highItem.high.doubleValue] attributes:@{NSFontAttributeName:self.yAxisTitleFont, NSForegroundColorAttributeName:self.yAxisTitleColor}];
    CGSize size = [attString boundingRectWithSize:CGSizeMake(MAXFLOAT, self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    self.leftMargin = size.width + 4.0f;
    
//更具宽度和间距确定要画多少个k线柱形图
    self.kLineDrawNum = floor(((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding) / (self.kLineWidth + self.kLinePadding)));
    
//确定从第几个开始画
    if (type == self.type) {
        self.startDrawIndex = self.chartValues.count - data.count;
    }else{
        //来到这里 说明是第一次点击 k 线 或者是通过滑动才会过来
        self.startDrawIndex = self.chartValues.count > 0 ? self.chartValues.count - self.kLineDrawNum : 0;
    }
    
    
    self.type = type;
    
    [self resetMaxAndMin];
    
    [self setNeedsDisplay];
}

#pragma mark - event reponse

- (void)updateChartPressed:(UIButton *)button {
    self.startDrawIndex = self.chartValues.count - self.kLineDrawNum;
}

- (void)tapEvent:(UITapGestureRecognizer *)tapGesture {
    if (self.chartValues.count == 0 || !self.chartValues) {
        return;
    }
    
    CGPoint touchPoint = [tapGesture locationInView:self];
    [self showTipBoardWithTouchPoint:touchPoint];
}


#pragma mark  ------------左滑动事件
- (void)panEvent:(UIPanGestureRecognizer *)panGesture {
    [self hideTipsWithAnimated:NO];
    CGPoint touchPoint = [panGesture translationInView:self];
    
    
//算出当前 移动的 距离 是 多少个 k线的宽度
    NSInteger offsetIndex = fabs(touchPoint.x/(self.kLineWidth > self.maxKLineWidth/2.0 ? 16.0f : 8.0));
    
    [self postNotificationWithGestureRecognizerStatus:panGesture.state];
    if (!self.scrollEnable || self.chartValues.count == 0 || offsetIndex == 0) {
        return;
    }
    
    /*
        self.startDrawIndex 是可视区域中  (比如当前最多显示 20个k线 这20个k线在数组中的位置 可能是 18 ~ 37) 最左边 的k线的 起始坐标(比如 18), 所以在他左边 可能还有坐标(17个)
        然后根据 偏移量 和 k线的宽度 可以算出 偏移了多少个
        所以要 减去 偏移的 k 线的个数, 重新算出位置(self.startDrawIndex)
     */

    if (touchPoint.x > 0) {
        //说明 手向右拉, 内容从左边出来, 要取数据(从数据源中还剩的中去取) , 如果 差值 < 0 说明 数据取完了, 直接为0, 否则就减去 偏移的 k线
        self.startDrawIndex = self.startDrawIndex - offsetIndex < 0 ? 0 : self.startDrawIndex - offsetIndex;
    }
    
    else { //手向左滑, 内容从右边出来, 说明数据绝对存在 的 不用去请求
        //
        self.startDrawIndex = self.startDrawIndex + offsetIndex ;
        
        if((self.startDrawIndex + self.kLineDrawNum) > self.chartValues.count){
            //说明到头了, 数据源中数据已经到最后(最大的那个下标) 这个时候 范围就直接 是   数组的长度 - 最大能画多少个k线(self.kLineDrawNum)
            self.startDrawIndex = self.chartValues.count - self.kLineDrawNum;
        }else{
            //说明 偏移k线的 个数 加上起始的 还没有到达最后, 直接加
            self.startDrawIndex = self.startDrawIndex + offsetIndex;
        }
    }

    [self resetMaxAndMin];
    
    [panGesture setTranslation:CGPointZero inView:self];
    [self setNeedsDisplay];
    
// 上面说了 self.starDrawIndex 代表 左边还剩多少个, 如果还剩 0 个, 表示要去服务器拿数据了, 也就是请求
    if (self.startDrawIndex == 0 && touchPoint.x > 0 ) {
          [_delegate  KLineChartViewNumber:self.type];
    }
}



/** 缩小放大 调用*/
- (void)pinchEvent:(UIPinchGestureRecognizer *)pinchEvent {
    [self hideTipsWithAnimated:NO];
    CGFloat scale = pinchEvent.scale - self.lastPanScale + 1;
    
    [self postNotificationWithGestureRecognizerStatus:pinchEvent.state];
    
    if (!self.zoomEnable || self.chartValues.count == 0) {
        return;
    }
    
//重新计算 k线的宽度 毕竟放大缩小了 可视范围内肯定会 显示的更多或更少 这里会调用 _KLineWidth的setter方法, 内部对传入的值 进行过滤, 必须在 self.minKLineWidth  和 self.maxKLineWidth之间
    self.kLineWidth = _kLineWidth*scale;
    
//保存 这一次绽放前 最多能画的k线的个数, 记住 当前缩放了, 本来 kLineDrawNum 应该变化的, 但变动的算法在下一行, 所以这里还是旧值
    CGFloat forwardDrawCount = self.kLineDrawNum;
    
//算出这种 当前比例下 应该能画 多少个k线
    _kLineDrawNum = floor((self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) / (self.kLineWidth + self.kLinePadding));
    
//容差处理 这句话的意思是 如果 在 放大或缩小的过程中, 最右边的如果 空余出的 位置的宽度  > 1个k线宽度 + 1个间距  他们和的 4/5 那么可以 可以多显示一个出来
    CGFloat diffWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin) - (self.kLineWidth + self.kLinePadding)*_kLineDrawNum;
    if (diffWidth > 4*(self.kLineWidth + self.kLinePadding)/5.0) {
        _kLineDrawNum = _kLineDrawNum + 1;
    }
    

//这句代码的解释 是在 resetMaxAndMin 中 证明了我的猜想
    _kLineDrawNum = self.chartValues.count > 0 && _kLineDrawNum < self.chartValues.count ? _kLineDrawNum : self.chartValues.count;
    
//这句话 是说 当前手势缩放或放大时的浮度很小, 导致上面   处理能画多少个k线的算法算出的  _kLineDrawNum 的值 没有发生 1个单位的变动  , 这里就直接返回, 不用重绘, 有助性能
//至于第二个条件 因为上面 对 _kLineWidth 调用了set方法, 这个方法内部会对 maxKLineWidth 作处理 目前不知道这个方法什么时候进来
    if (forwardDrawCount == self.kLineDrawNum && self.maxKLineWidth != self.kLineWidth) {
        return;
    }
    
    
//算出 之前和现在变动的个数
    NSInteger diffCount = fabs(self.kLineDrawNum - forwardDrawCount);
    
//算出可视范围内起点的坐标
    if (forwardDrawCount > self.startDrawIndex) { //手势放大的情况
        self.startDrawIndex += ceil(diffCount/2.0);
    } else { //手势缩小的情况
        self.startDrawIndex -= floor(diffCount/2.0);
        self.startDrawIndex = self.startDrawIndex < 0 ? 0 : self.startDrawIndex;
    }
    
//如果 当前算出的 起点下标 + 最多可画的个数 > 数据源的总个数, 就直接 画数组中最后的几个 self.kLineDrawNum, 否则 范围是数据源中的 self.startDrawIndex 到 self.starDrawIndex + self.kLineDrawNum 这个下标范围
    self.startDrawIndex = self.startDrawIndex + self.kLineDrawNum > self.chartValues.count ? self.chartValues.count - self.kLineDrawNum : self.startDrawIndex;
    
    [self resetMaxAndMin];
    
    pinchEvent.scale = scale;
    self.lastPanScale = pinchEvent.scale;
    
    [self setNeedsDisplay];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longGesture {
    [self postNotificationWithGestureRecognizerStatus:longGesture.state];
    
    if (self.chartValues.count == 0 || !self.chartValues) {
        return;
    }
    
    if (longGesture.state == UIGestureRecognizerStateEnded) {
        [self hideTipsWithAnimated:NO];
    } else {
        CGPoint touchPoint = [longGesture locationInView:self];
        [self showTipBoardWithTouchPoint:touchPoint];
    }
}

- (void)showTipBoardWithTouchPoint:(CGPoint)touchPoint {
    /** 
        下面这个数组中 是当初为了方便 将 k线的下标索引(数据源中) 和  k线的x坐标  存储起来了 一一对应
            
        应该是在画k线的时候存储的
     */
    
    
/// 遍历字典的 key 和 value 去找 哪一个 k 线被 点击了
    [self.xAxisContext enumerateKeysAndObjectsUsingBlock:^(NSNumber *xAxisKey, NSNumber *indexObject, BOOL *stop) {

/// 点击的点 在 0 到 1个k线 + 1个间距 的范围内 就是要找的 目标
        if (_kLinePadding+_kLineWidth >= ([xAxisKey doubleValue] - touchPoint.x) && ([xAxisKey doubleValue] - touchPoint.x) > 0) {
            NSInteger index = [indexObject integerValue];
            
// 获取对应的k线数据
            KLineItem *item = self.chartValues[index];
            CGFloat open = [item.open doubleValue];
            CGFloat close = [item.close doubleValue];
            
//处出 比例
            CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
            scale = scale == 0 ? 1.0 : scale;
   
      
// 算出  要显示到合适的位置
            CGFloat xAxis = [xAxisKey doubleValue] - _kLineWidth / 2.0 + (self.fullScreen ? 0 : self.leftMargin);
            CGFloat yAxis = self.yAxisHeight - (open - self.minLowValue)/scale + self.topMargin;
            
            if ([item.high doubleValue] > [item.low doubleValue]) {
                yAxis = self.yAxisHeight - (close - self.minLowValue)/scale + self.topMargin;
            }
            
            [self configUIWithLineItem:item atPoint:CGPointMake(xAxis, yAxis)];
            
            *stop = YES;
        }
    }];
}

#pragma mark ---------  #warning 提示版  数据

- (void)configUIWithLineItem:(KLineItem *)item atPoint:(CGPoint)point {
 
    self.verticalCrossLine.hidden = NO;
    CGRect frame = self.verticalCrossLine.frame;
    frame.origin.x = point.x;
    frame.size.height = self.showBarChart ? self.frame.size.height - self.topMargin : frame.size.height;
    self.verticalCrossLine.frame = frame;
//如果显示柱状图的话, 就将  垂直的线  延长到 屏幕最下方
    
    
    
    self.horizontalCrossLine.hidden = NO;
    frame = self.horizontalCrossLine.frame;
    frame.origin.y = point.y;
    self.horizontalCrossLine.frame = frame;
//上面的 水平 和 垂直  的 线 是点击 k线 后出现的 灰色的 十字线  不是阴阳线 别搞错了
    
    
//这个线不知道干什么的 垂直的 宽0.5
    self.barVerticalLine.hidden = NO;
    frame = self.barVerticalLine.frame;
    frame.origin.x = point.x;
    self.barVerticalLine.frame = frame;
    
    
    self.tipBoard.open = [NSString stringWithFormat:@"%@", item.open];
    self.tipBoard.close = [NSString stringWithFormat:@"%@", item.close];
    self.tipBoard.high = [NSString stringWithFormat:@"%@", item.high];
    self.tipBoard.low = [NSString stringWithFormat:@"%@", item.low];
    self.tipBoard.totalMoney = [NSString stringWithFormat:@"%@", item.totalMoney];
    self.tipBoard.marketPrice = [NSString stringWithFormat:@"%@", item.marketPrice];
    self.tipBoard.investPerson = [NSString stringWithFormat:@"%@", item.investPerson];
    
    
//这些判断是让 提示板放到 合适的位置(主要是Y坐标)
    if (point.y - self.topMargin - self.tipBoard.frame.size.height/2.0 < 0) {
        point.y = self.topMargin;
        
        
    } else if ((point.y - self.tipBoard.frame.size.height/2.0) > self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f) {
        point.y = self.topMargin + self.yAxisHeight - self.tipBoard.frame.size.height*3/2.0f;
    } else {
        point.y -= self.tipBoard.frame.size.height / 2.0;
        
    }
    
    if (point.y<0) {
        point.y = 0;
    }
    
    
    //计算宽度
    NSString *totalMoney = [NSString stringWithFormat:@"%@", item.totalMoney];
    totalMoney= [Global textWithMoney:[totalMoney floatValue] andType:0];
    NSArray *titles = @[[@"微基金   ：" stringByAppendingString:[NSString stringWithFormat:@"%.2f%%",[item.close doubleValue]*100]], [@"沪深300：" stringByAppendingString:[NSString stringWithFormat:@"%.2f%%",[item.marketPrice doubleValue]*100]],[@"总资金   ：" stringByAppendingString:totalMoney],[@"投资数   ：" stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)[item.investPerson integerValue]]]];
    
    CGSize size = [Global getSizeOfString:titles[0] maxWidth:300 maxHeight:100 withFontSize:10];
    for (NSInteger i=1; i<titles.count; i++) {
        
        CGSize sizeWidth = [Global getSizeOfString:titles[i] maxWidth:300 maxHeight:100 withFontSize:10];
        if (size.width<sizeWidth.width) {
            size = sizeWidth;
        }
    }
    
    frame = self.tipBoard.frame;
    frame.size.width = size.width + Adaptor_Value(20.0f);
    
    self.tipBoard.frame = frame;
    
    [self.tipBoard showWithTipPoint:CGPointMake(point.x, point.y)];
    
    
    
//下面这些是 显示提示板后显示在 下方柱状图上方的 时间的设置
    NSString *date = item.date;
    self.timeLbl.text = date;
    self.timeLbl.hidden = date.length > 0 ? NO : YES;
    [self bringSubviewToFront:self.timeLbl];

    
    if (date.length > 0) {
        CGSize size = [date boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.xAxisTitleFont} context:nil].size;
        CGFloat originX = MIN(MAX(0, point.x - size.width/2.0 - 2), self.frame.size.width - self.rightMargin - size.width - 4);
         self.timeLbl.frame = CGRectMake(originX, self.topMargin + self.yAxisHeight + self.separatorWidth+12, size.width + 4, self.timeAxisHeight - self.separatorWidth*2 - 8);
        
    }
    
}

- (void)hideTipsWithAnimated:(BOOL)animated {
    self.horizontalCrossLine.hidden = YES;
    self.verticalCrossLine.hidden = YES;
    self.barVerticalLine.hidden = YES;
    self.maTipView.hidden = YES;
    self.priceLbl.hidden = YES;
    self.timeLbl.hidden = YES;
    if (animated) {
        [self.tipBoard hide];
    } else {
        self.tipBoard.hidden = YES;
    }
}

- (void)postNotificationWithGestureRecognizerStatus:(UIGestureRecognizerState)state {
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyStartUserInterfaceNotification object:nil];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [[NSNotificationCenter defaultCenter] postNotificationName:KLineKeyEndOfUserInterfaceNotification object:nil];
            break;
        }
        default:
            break;
    }
}

#pragma mark - private methods

/**
 *  网格（坐标图）
 */
- (void)drawAxisInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //k线边框
    CGRect strokeRect = CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, self.xAxisWidth, self.yAxisHeight);
    CGContextSetLineWidth(context, self.axisShadowWidth);
    CGContextSetStrokeColorWithColor(context, self.axisShadowColor.CGColor);
    CGContextStrokeRect(context, strokeRect);
    
    //k线分割线
    CGFloat avgHeight = strokeRect.size.height/5.0;
    for (int i = 1; i <= 4; i ++) {
        [self drawDashLineInContext:context
                          movePoint:CGPointMake((self.fullScreen ? 0 : self.leftMargin) + 1.25, self.topMargin + avgHeight*i)
                            toPoint:CGPointMake(rect.size.width  - self.rightMargin - 0.8, self.topMargin + avgHeight*i)];
    }
    
    //这必须把dash给初始化一次，不然会影响其他线条的绘制
    CGContextSetLineDash(context, 0, 0, 0);
}

- (void)drawYAxisTitle {
    //k线y坐标
    CGFloat avgValue = (self.maxHighValue - self.minLowValue) / 5.0;
    for (int i = 0; i < 6; i ++) {
        float yAxisValue = i == 5 ? self.minLowValue : self.maxHighValue - avgValue*i;
        
        NSString *priceStr = [NSString stringWithFormat:@"%.2f%%",[[NSString stringWithFormat:@"%f",yAxisValue] doubleValue]*100];

        NSAttributedString *attString = [Global_Helper attributeText:priceStr textColor:self.yAxisTitleColor font:self.yAxisTitleFont];
        CGSize size = [attString boundingRectWithSize:CGSizeMake((self.fullScreen ? 0 : self.leftMargin), self.yAxisTitleFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        CGFloat diffHeight = 0;
        if (i == 5) {
            diffHeight = size.height;
        } else if (i > 0 && i < 5) {
            diffHeight = size.height/2.0;
        }
        [attString drawInRect:CGRectMake((self.fullScreen ? 2.0 : self.leftMargin - size.width - 2.0f), self.topMargin + self.yAxisHeight/5.0*i - diffHeight, size.width, size.height)];
    }
}

- (void)drawDashLineInContext:(CGContextRef)context
                    movePoint:(CGPoint)mPoint toPoint:(CGPoint)toPoint {
    CGContextSetLineWidth(context, self.separatorWidth);
    CGFloat lengths[] = {5,5};
    CGContextSetStrokeColorWithColor(context, self.separatorColor.CGColor);
    CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mPoint.x, mPoint.y);    //开始画线
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y);
    
    CGContextStrokePath(context);
}

- (void)drawTimeAxis {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSInteger index = self.chartValues.count > self.kLineDrawNum ?  self.kLineDrawNum: self.kLineDrawNum;
    
    CGFloat quarteredWidth = index*((_kLinePadding + _kLineWidth));
    
    NSInteger avgDrawCount = index - 1;
    
    CGFloat xAxis = (self.fullScreen ? 0 : self.leftMargin) + _kLineWidth/2.0 + _kLinePadding;
    
    
    //画4条虚线
    for (int i = 0; i < 2; i ++) {
        if (xAxis > (self.fullScreen ? 0 : self.leftMargin) + self.xAxisWidth) {
            break;
        }
        [self drawDashLineInContext:context movePoint:CGPointMake(xAxis, self.topMargin + 1.25) toPoint:CGPointMake(xAxis, self.topMargin + self.yAxisHeight - 1.25)];
        //x轴坐标
        NSInteger timeIndex = i*avgDrawCount + self.startDrawIndex;
//        NSLog(@"%ld      %ld      %ld",(long)self.startDrawIndex,(long)timeIndex,self.chartValues.count);
        
        if (i==0) {
            NSAttributedString *attString = [Global_Helper attributeText:self.chartValues[timeIndex].date textColor:self.xAxisTitleColor font:self.xAxisTitleFont lineSpacing:2];
            CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
            [attString drawInRect:CGRectMake(0, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
        }else{
            
            if (timeIndex>5) {
                NSAttributedString *attString = [Global_Helper attributeText:self.chartValues[timeIndex].date textColor:self.xAxisTitleColor font:self.xAxisTitleFont lineSpacing:2];
                CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
                if (self.chartValues.count > self.kLineDrawNum) {
                    [attString drawInRect:CGRectMake(quarteredWidth-size.width, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
                }else{
                    [attString drawInRect:CGRectMake(quarteredWidth-size.width+_kLinePadding+_kLineWidth, self.topMargin + self.yAxisHeight + 2.0, size.width, size.height)];
                }
            }
            
        }
        
    }
    CGContextSetLineDash(context, 0, 0, 0);
}

/**
 *  K线
 */
- (void)drawKLine {
    CGFloat scale = (self.maxHighValue - self.minLowValue) / self.yAxisHeight;
    if (scale == 0) {
        scale = 1.0;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 0.5);
    
    CGFloat xAxis = _kLinePadding;
    [self.xAxisContext removeAllObjects];
    
//    CGPoint maxPoint, minPoint;
    
    for (KLineItem *item in [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
        [self.xAxisContext setObject:@([self.chartValues indexOfObject:item]) forKey:@(xAxis + _kLineWidth)];
        //通过开盘价、收盘价判断颜色

        CGFloat open = [item.open doubleValue];
        CGFloat close = [item.close doubleValue];
        
//        NSLog(@"%f    %f",open,close);
        
        UIColor *fillColor = open > close ? self.positiveLineColor : self.negativeLineColor;
        CGContextSetFillColorWithColor(context, fillColor.CGColor);
        CGContextSetStrokeColorWithColor(context, fillColor.CGColor);
        CGContextBeginPath(context);
        
        CGFloat diffValue = fabs(open - close);
        CGFloat maxValue = MAX(open, close);
        CGFloat height = diffValue/scale == 0 ? 0.5 : diffValue/scale;
    
        CGFloat width = _kLineWidth;
        CGFloat yAxis = self.yAxisHeight - ((maxValue - self.minLowValue)/scale == 0 ? 1 : (maxValue - self.minLowValue)/scale) + self.topMargin;
        
        CGRect rect = CGRectMake(xAxis + (self.fullScreen ? 0 : self.leftMargin), yAxis, width, height);
        CGContextAddRect(context, rect);
        if (open>close) {
            CGContextFillPath(context);
        }else{
            CGContextStrokePath(context);
        }
        
        
        //上、下影线
        CGFloat highYAxis = self.yAxisHeight - ([item.high doubleValue] - self.minLowValue)/scale;
        CGFloat lowYAxis = self.yAxisHeight - ([item.low doubleValue] - self.minLowValue)/scale;
        CGPoint highPoint = CGPointMake(xAxis + width/2.0 + (self.fullScreen ? 0 : self.leftMargin), highYAxis + self.topMargin);
        CGPoint lowPoint = CGPointMake(xAxis + width/2.0 + (self.fullScreen ? 0 : self.leftMargin), lowYAxis + self.topMargin);
        
        
        CGContextMoveToPoint(context, highPoint.x, highPoint.y);  //起点坐标
        CGContextAddLineToPoint(context, lowPoint.x, lowPoint.y);   //终点坐标
        CGContextStrokePath(context);
        
        if (open<close) {
            CGRect rect2 = CGRectMake(xAxis + (self.fullScreen ? 0 : self.leftMargin)+0.5, yAxis+0.5, width-1, height-1);
            CGContextAddRect(context, rect2);
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//实心
            CGContextFillPath(context);//实心
        }
        
        
//        if ([item.high doubleValue] == self.maxHighValue) {
//            maxPoint = highPoint;
//        }
//        
//        if ([item.low doubleValue] == self.minLowValue) {
//            minPoint = lowPoint;
//        }
        
        xAxis += width + _kLinePadding;
    }
    
    //显示当前页面最高价 和 最低价
    
//    NSAttributedString *attString = [Global_Helper attributeText:[self dealDecimalWithNum:@(self.maxHighValue)] textColor:HexRGB(0xFFB54C) font:[UIFont systemFontOfSize:12.0f]];
//    CGSize size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(100, 100)];
//    float originX = maxPoint.x - size.width - self.kLineWidth - 2 < (self.fullScreen ? 0 : self.leftMargin) + self.kLineWidth + 2.0 ?  maxPoint.x + self.kLineWidth : maxPoint.x - size.width - self.kLineWidth;
//    [attString drawInRect:CGRectMake(originX, maxPoint.y, size.width, size.height)];
//    
//    attString = [Global_Helper attributeText:[self dealDecimalWithNum:@(self.minLowValue)] textColor:HexRGB(0xFFB54C) font:[UIFont systemFontOfSize:12.0f]];
//    size = [Global_Helper attributeString:attString boundingRectWithSize:CGSizeMake(100, 100)];
//    originX = minPoint.x - size.width - self.kLineWidth - 2 < (self.fullScreen ? 0 : self.leftMargin) + self.kLineWidth + 2.0 ?  minPoint.x + self.kLineWidth : minPoint.x - size.width - self.kLineWidth;
//    [attString drawInRect:CGRectMake(originX, self.yAxisHeight - size.height + self.topMargin, size.width, size.height)];
}

#pragma mark------------ 下面可以选 大盘颜色 大盘数量 就是下面的那个1  大盘path 可以选择大盘数据
/**
 *  大盘图
 */
- (void)drawMALine {
    if (!self.showAvgLine) {
        return;
    }
    
    NSArray<UIColor *> *colors = @[self.minMALineColor, self.midMALineColor, self.maxMALineColor];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.movingAvgLineWidth);

    for (int i = 0; i < 1; i ++) {
        CGContextSetStrokeColorWithColor(context, colors[i].CGColor);
        CGPathRef path = [self movingAvgGraphPathForContextAtIndex:i];
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
    }
}

#pragma mark ------------ 大盘path   下面上面跑出去  怪下面这个path 15  改成1就变成直线了

- (CGPathRef)movingAvgGraphPathForContextAtIndex:(NSInteger)index {
    UIBezierPath *path;
    
    CGFloat xAxis = (self.fullScreen ? 0 : self.leftMargin) + 1/2.0*_kLineWidth + _kLinePadding;
    CGFloat scale = (self.maxHighValue - self.minLowValue ) / self.yAxisHeight;
    
    if (scale != 0) {
        for (KLineItem *item in [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, self.kLineDrawNum)]) {
//            NSAssert(item.MAs.count == self.numberOfMACount, @"均线显示个数，和设置不一致！");
            CGFloat maValue = [item.marketPrice doubleValue];
            
            CGFloat yAxis = self.yAxisHeight - (maValue - self.minLowValue)/scale + self.topMargin;
            
            CGPoint maPoint = CGPointMake(xAxis, yAxis);
            if (yAxis < self.topMargin || yAxis > (self.frame.size.height - self.bottomMargin)) {
                xAxis += self.kLineWidth + self.kLinePadding;
                continue;
            }

            if (!path) {
                path = [UIBezierPath bezierPath];
                [path moveToPoint:maPoint];
            } else {
                [path addLineToPoint:maPoint];
            }
            
            xAxis += self.kLineWidth + self.kLinePadding;
            
//            NSLog(@" %f    %f    %f       %f",xAxis,yAxis,maPoint.x,maPoint.y);
        }
    }
    
    //圆滑
    path = [path smoothedPathWithGranularity:15];
    
    return path.CGPath;
    
    
}

#pragma mark  --------  交易量     资金量 投资人数

- (void)drawVol {
    if (!self.showBarChart) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.kLineWidth);
    
    CGRect rect = self.bounds;
    
//他的数据源是在 drawChartWithData 中进去 就拿到了
    CGFloat boxOriginY = self.topMargin + self.yAxisHeight + self.timeAxisHeight + 5;
    CGFloat boxHeight = rect.size.height - boxOriginY;
    self.volView.frame = CGRectMake(0, boxOriginY, rect.size.width, boxHeight);
    self.volView.kLineWidth = self.kLineWidth;
    self.volView.linePadding = self.kLinePadding;
    self.volView.boxOriginX = (self.fullScreen ? 0 : self.leftMargin);
    
    self.volView.startDrawIndex = self.startDrawIndex;
    self.volView.numberOfDrawCount = self.kLineDrawNum;
    [self.volView update];
}

#pragma mark --------资金量  投资人数   得到最大最小值

- (void)resetMaxAndMin {
    self.maxHighValue = -MAXFLOAT;
    self.minLowValue = MAXFLOAT;
    
/**
    这句代码的解析 假设 是从 init data那边过来的
 
        首先如果 self.YaxisTitleIsChange 是 YES 表示要实现 在当前正显示视图中 找到最大值, 最小值的k线, 然后设置y轴的最大值, 最小值, 如果滑动导致数据源(显示在用户眼前的数据,因为屏幕是有限的)更换, 将在新的数据源中再去寻找最新的 可视区域中最大和最小的 k线, 然后赋值给y轴的最大值和最小值, 这们就行成了动态
 
                如果为NO, 表示 在这次请求的数据源里找到最大和最小的值, 然后赋值给y轴的最大和最小, 如果滑动导致可视区域中数据源变动(这个时候, 如果没有将第1次数据源的所有数据用完, 也就是没有去请求新的数据),将不会更改, 这就是所谓的静态
 
 
            好了, 上面是要 实现的功能, 如何实现?
 
        1 确定当前可视区域里 可视数据源的 起始位置
            - 假如:  屏幕在 横屏方向最多能画 100个, 在竖屏方向时最多能画20个  这个值就是  self.kLineDrawNum
            - 上面确定了范围
            - 开始的位置 其实就是用 数据源的总个数(下标是最后1个) - 范围(self.kLineDrawNum)  这个值 (这个值必须有效 也就是要  > 0)
                * 他直接这样写, 说明了 数据源的个数不管在横屏下还是在竖屏下都比 self.kLineDrawNum 大
            - 结束的位置 
                * 这个是要分情况的, 如果数据源的个数 40个, 那么当是 横屏时, 应该取40, 而不是取self.kLineDrawNum(这个时候的值是100)
        lable_1:* 如果是在竖屏下, 应该取 self.kLineDrawNum(这个时候是20), 而不是 到数据源的最后一个(如果取这个, 会导致位置不够画)
                * label_1的这种情况可能是缩放 导致 self.kLineDrawNum 会增大或减小(缩放的时候, 会增大,反之,减小)
                * 总之 取最小的那个, 关于self.kLineDrawNum应该是动态根据 缩放比例改变的, 说明 缩放的代理中也会调用这个方法
 
 
 
        2 找到1中确定数据源中的最大和最小值
            *遍历
            *比较
            *符合条件赋值
 
 */
    NSArray *drawContext = self.yAxisTitleIsChange ? [self.chartValues subarrayWithRange:NSMakeRange(self.startDrawIndex, MIN(self.kLineDrawNum, self.chartValues.count))] : self.chartValues;

    for (int i = 0; i < drawContext.count; i++) {
        
        KLineItem *item = drawContext[i];
        
        self.maxHighValue = MAX([item.high doubleValue] , self.maxHighValue);
        self.minLowValue = MIN([item.low doubleValue] , self.minLowValue);
        
//如果不展示大盘曲线
        if (!self.show) {
            if ([item.marketPrice doubleValue]>self.maxHighValue) {
                self.maxHighValue = MAX([item.marketPrice doubleValue]  , self.maxHighValue);
            }
            
            if ([item.marketPrice doubleValue]<self.minLowValue) {
                self.minLowValue = MIN([item.marketPrice doubleValue] , self.minLowValue);
            }
        }
        
//缩放了 50 倍
        double height = (self.maxHighValue - self.minLowValue)*0.02;
        self.maxHighValue = self.maxHighValue + height;
        self.minLowValue = self.minLowValue - height;
    }
}

- (NSString *)dealDecimalWithNum:(NSNumber *)num {
    NSString *dealString;
    
    switch (self.saveDecimalPlaces) {
        case 0: {
            dealString = [NSString stringWithFormat:@"%ld", lroundf(num.doubleValue)];
        }
            break;
        case 1: {
            dealString = [NSString stringWithFormat:@"%.1f", num.doubleValue];
        }
            break;
        case 2: {
            dealString = [NSString stringWithFormat:@"%.2f", num.doubleValue];
        }
            break;
        default:
            break;
    }
    
    return dealString;
}

#pragma mark -  public methods

- (void)clear {
    self.chartValues = nil;
    [self setNeedsDisplay];
}

#pragma mark - notificaiton events

- (void)startTouchNotification {
    self.interactive = YES;
}

- (void)endOfTouchNotification {
    self.interactive = NO;
}

#pragma mark - getters

- (VolumnView *)volView {
    if (!_volView) {
        _volView = [VolumnView new];
        _volView.backgroundColor  = self.backgroundColor;
        _volView.boxRightMargin = self.rightMargin;
        _volView.axisShadowColor = self.axisShadowColor;
        _volView.axisShadowWidth = self.axisShadowWidth;
        _volView.negativeVolColor = self.negativeVolColor;
        _volView.positiveVolColor = self.positiveVolColor;
        _volView.yAxisTitleFont = self.yAxisTitleFont;
        _volView.yAxisTitleColor = self.yAxisTitleColor;
        _volView.separatorWidth = self.separatorWidth;
        _volView.separatorColor = self.separatorColor;
        [self addSubview:_volView];
    }
    return _volView;
}

- (UIView *)verticalCrossLine {
    if (!_verticalCrossLine) {
        _verticalCrossLine = [[UIView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, 0.5, self.yAxisHeight)];
        _verticalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_verticalCrossLine];
    }
    return _verticalCrossLine;
}

- (UIView *)horizontalCrossLine {
    if (!_horizontalCrossLine) {
        _horizontalCrossLine = [[UIView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, self.xAxisWidth, 0.5)];
        _horizontalCrossLine.backgroundColor = self.crossLineColor;
        [self addSubview:_horizontalCrossLine];
    }
    return _horizontalCrossLine;
}

- (UIView *)barVerticalLine {
    if (!_barVerticalLine) {
        CGRect rect = {
            self.fullScreen ? 0 : self.leftMargin,
            self.topMargin + self.yAxisHeight + self.timeAxisHeight,
            0.5,
            self.frame.size.height - (self.topMargin + self.yAxisHeight + self.timeAxisHeight)
        };
        _barVerticalLine = [[UIView alloc] initWithFrame:rect];
        
        _barVerticalLine.backgroundColor = self.crossLineColor;
        [self addSubview:_barVerticalLine];
    }
    return _barVerticalLine;
}

#pragma mark ------------ 提示板高度

- (KLineTipBoardView *)tipBoard {
    if (!_tipBoard) {
        _tipBoard = [[KLineTipBoardView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin), self.topMargin, 115.0f, [UIFont systemFontOfSize:10.0f].lineHeight*7.0f + 8*2)];
        _tipBoard.backgroundColor = [UIColor clearColor];
        _tipBoard.font = [UIFont systemFontOfSize:10.0f];
        [self addSubview:_tipBoard];
    }
    return _tipBoard;
}

- (MATipView *)maTipView {
    if (!_maTipView) {
        _maTipView = [[MATipView alloc] initWithFrame:CGRectMake((self.fullScreen ? 0 : self.leftMargin) + 20, self.topMargin - 18.0f, self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - 20, 13.0f)];
        _maTipView.layer.masksToBounds = YES;
        _maTipView.layer.cornerRadius = 7.0f;
        _maTipView.backgroundColor = [UIColor colorWithWhite:0.35 alpha:1.0];
        [self addSubview:_maTipView];
    }
    return _maTipView;
}

- (UIButton *)realDataTipBtn {
    if (!_realDataTipBtn) {
        _realDataTipBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_realDataTipBtn setTitle:@"New Data" forState:UIControlStateNormal];
        [_realDataTipBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        _realDataTipBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
        _realDataTipBtn.frame = CGRectMake(self.frame.size.width - self.rightMargin - 60.0f, self.topMargin + 10.0f, 60.0f, 25.0f);
        [_realDataTipBtn addTarget:self action:@selector(updateChartPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_realDataTipBtn];
        _realDataTipBtn.layer.borderWidth = 1.0;
        _realDataTipBtn.layer.borderColor = [UIColor redColor].CGColor;
        _realDataTipBtn.hidden = YES;
    }
    return _realDataTipBtn;
}

- (UILabel *)timeLbl {
    if (!_timeLbl) {
        _timeLbl = [UILabel new];
        _timeLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        _timeLbl.font = self.yAxisTitleFont;
        _timeLbl.textColor = self.timeAndPriceTextColor;
        _timeLbl.numberOfLines = 0;
        [self addSubview:_timeLbl];
    }
    return _timeLbl;
}

- (UILabel *)priceLbl {
    if (!_priceLbl) {
        _priceLbl = [UILabel new];
        _priceLbl.backgroundColor = self.timeAndPriceTipsBackgroundColor;
        _priceLbl.textAlignment = NSTextAlignmentCenter;
        _priceLbl.font = [UIFont systemFontOfSize:self.xAxisTitleFont.pointSize + 2.0];
        _priceLbl.textColor = self.timeAndPriceTextColor;
        [self addSubview:_priceLbl];
    }
    return _priceLbl;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panEvent:)];
    }
    return _panGesture;
}

- (UIPinchGestureRecognizer *)pinchGesture {
    if (!_pinchGesture) {
        _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchEvent:)];
    }
    return _pinchGesture;
}

- (UILongPressGestureRecognizer *)longGesture {
    if (!_longGesture) {
        _longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressEvent:)];
    }
    return _longGesture;
}

#pragma mark - setters 

- (void)setChartValues:(NSMutableArray<KLineItem *> *)chartValues {
    _chartValues = chartValues;
    
    CGFloat maxHigh = -MAXFLOAT;
    for (KLineItem *item in self.chartValues) {
        if (item.high.doubleValue > maxHigh) {
            maxHigh = item.high.doubleValue;
            self.highItem = item;
        }
    }
}

- (void)setKLineDrawNum:(NSInteger)kLineDrawNum {
    _kLineDrawNum = MAX(MIN(self.chartValues.count, kLineDrawNum), 0);
    
    if (_kLineDrawNum != 0) {
        self.kLineWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding)/_kLineDrawNum - _kLinePadding;
    }
}

- (void)setKLineWidth:(CGFloat)kLineWidth { // 5 ~ 10   7
//这个式子表明 一个过滤条件,  传进来的kLineWidth的范围 限定在了  self.minKLineWidth  和 self.maxKLineWidth之间 很装逼的写法
    _kLineWidth = MIN(MAX(kLineWidth, self.minKLineWidth), self.maxKLineWidth);
}

- (void)setMaxKLineWidth:(CGFloat)maxKLineWidth {
    if (maxKLineWidth < _minKLineWidth) {
        maxKLineWidth = _minKLineWidth;
    }
    
    CGFloat realAxisWidth = (self.frame.size.width - (self.fullScreen ? 0 : self.leftMargin) - self.rightMargin - _kLinePadding);
    NSInteger maxKLineCount = floor(realAxisWidth)/(maxKLineWidth + _kLinePadding);
    maxKLineWidth = realAxisWidth/maxKLineCount - _kLinePadding;
    
    _maxKLineWidth = maxKLineWidth;
}

/** 当间距发生变化后 就要重新计算出坐标的真实宽度 和 最多能画的个数*/
- (void)setLeftMargin:(CGFloat)leftMargin {
    _leftMargin = leftMargin;
    
    self.maxKLineWidth = _maxKLineWidth; //调用set方法重新计算
}

- (void)setSupportGesture:(BOOL)supportGesture {
    _supportGesture = supportGesture;
    
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        gesture.enabled = supportGesture;
    }
}

- (void)setNumberOfMACount:(NSInteger)numberOfMACount {
    _numberOfMACount = numberOfMACount;
}

- (void)setBottomMargin:(CGFloat)bottomMargin {
    _bottomMargin = bottomMargin < _timeAxisHeight ? _timeAxisHeight : bottomMargin;
}

@end
