//
//  ZCircleSlider.m
//  LoadingView
//
//  Created by ZhangBob on 24/05/2017.
//  Copyright © 2017 JixinZhang. All rights reserved.
//

#import "ZCircleSlider.h"
#import "NSImageView+ZCircle.h"

@interface ZCircleSlider()

@property (nonatomic, strong) NSImageView *thumbView;
@property (nonatomic, assign) CGPoint lastPoint;        //滑块的实时位置

@property (nonatomic, assign) CGFloat radius;           //半径
@property (nonatomic, assign) CGPoint drawCenter;       //绘制圆的圆心
@property (nonatomic, assign) CGPoint circleStartPoint; //thumb起始位置
@property (nonatomic, assign) CGFloat angle;            //转过的角度

@property (nonatomic, assign) BOOL lockClockwise;       //禁止顺时针转动
@property (nonatomic, assign) BOOL lockAntiClockwise;   //禁止逆时针转动

@property (nonatomic, assign) BOOL interaction;

@end

@implementation ZCircleSlider

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"angle"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

/**
 设定默认值
 */
- (void)setup {
//    self.backgroundColor = [UIColor clearColor];
    self.circleRadius = MIN(self.frame.size.width, self.frame.size.height) - 24;
    self.circleBorderWidth = 5.0f;
    self.thumbRadius = 12.0f;
    self.thumbExpandRadius = 25.0f;
    self.maximumTrackTintColor = [NSColor lightGrayColor];
    self.minimumTrackTintColor = [NSColor blueColor];
    
    self.drawCenter = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    self.circleStartPoint = CGPointMake(self.drawCenter.x , self.drawCenter.y - self.circleRadius);
    self.loadProgress = 1.0;
    self.interaction = NO;
    self.canRepeat = NO;
    self.angle = 0;
    self.lockAntiClockwise = YES;
    self.lockClockwise = NO;
    [self addSubview:self.thumbView];
    
    [self addObserver:self
           forKeyPath:@"angle"
              options:NSKeyValueObservingOptionNew
              context:nil];
}

#pragma mark - getter

- (NSImageView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[NSImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _thumbView.image = [NSImage imageNamed:@"thumbSlider"];

        _thumbView.wantsLayer = YES;
        _thumbView.layer.masksToBounds = YES;
       // _thumbView. = NO;

    }
    return _thumbView;
}

#pragma mark - setter

- (void)setValue:(float)value {
    if (value < 0.25) {
        self.lockClockwise = NO;
    } else {
        self.lockAntiClockwise = NO;
    }
    _value = MIN(MAX(value, 0.0), 0.997648);
    [self setNeedsDisplay];
}

- (void)setLoadProgress:(float)loadProgress {
    _loadProgress = loadProgress;
    [self setNeedsDisplay];
}

- (void)setCanRepeat:(BOOL)canRepeat {
    _canRepeat = canRepeat;
    [self setNeedsDisplay];
}

- (void)setThumbRadius:(CGFloat)thumbRadius {
    _thumbRadius = thumbRadius;
    self.thumbView.frame = CGRectMake(0, 0, thumbRadius * 2, thumbRadius * 2);
    self.thumbView.layer.cornerRadius = thumbRadius;

    [self setNeedsDisplay];
}

- (void)setThumbExpandRadius:(CGFloat)thumbExpandRadius {
    _thumbExpandRadius = thumbExpandRadius;
    [self setNeedsDisplay];
}

- (void)setCircleRadius:(CGFloat)circleRadius {
    _circleRadius = circleRadius;
    self.circleStartPoint = CGPointMake(self.drawCenter.x, self.drawCenter.y - self.circleRadius);
    [self setNeedsDisplay];
}

- (void)setCircleBorderWidth:(CGFloat)circleBorderWidth {
    _circleBorderWidth = circleBorderWidth;
    [self setNeedsDisplay];
}

- (void)setMinimumTrackTintColor:(NSColor *)minimumTrackTintColor {
    _minimumTrackTintColor = minimumTrackTintColor;
    [self setNeedsDisplay];
}

- (void)setMaximumTrackTintColor:(NSColor *)maximumTrackTintColor {
    _maximumTrackTintColor = maximumTrackTintColor;
    [self setNeedsDisplay];
}

- (void)setThumbTintColor:(NSColor *)thumbTintColor {
    _thumbTintColor = thumbTintColor;
    
    self.thumbView.layer.backgroundColor = thumbTintColor.CGColor;
    
    [self setNeedsDisplay];
}

#pragma mark - drwRect

- (void)drawRect:(CGRect)rect {
    self.drawCenter = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    self.radius = self.circleRadius;
    self.circleStartPoint = CGPointMake(self.drawCenter.x - self.circleRadius/2, self.drawCenter.y - sqrt(3)/2*self.circleRadius);

    CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
    //圆形的背景颜色
    CGContextSetStrokeColorWithColor(ctx, self.backgroundTintColor.CGColor);
    CGContextSetLineWidth(ctx, 1);
   // CGContextAddArc(<#CGContextRef  _Nullable c#>, <#CGFloat x#>, <#CGFloat y#>, <#CGFloat radius#>, <#CGFloat startAngle#>, <#CGFloat endAngle#>, <#int clockwise#>)
    CGContextAddArc(ctx, self.drawCenter.x, self.drawCenter.y, self.radius, -M_PI/3,  M_PI + M_PI/3, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
  
//    //加载的进度
    NSBezierPath *loadPath = [NSBezierPath bezierPath];
    CGFloat loadStart = -M_PI_2 * 5/6;
    CGFloat loadCurre = loadStart + 2/3 * M_PI * self.loadProgress;

    CGContextSetStrokeColorWithColor(ctx, self.maximumTrackTintColor.CGColor);
    CGContextSetLineWidth(ctx, self.circleBorderWidth);
    [loadPath appendBezierPathWithArcWithCenter:self.drawCenter radius:self.radius startAngle:loadStart endAngle:loadCurre clockwise:NO];
//    [loadPath addArcWithCenter:self.drawCenter
//                        radius:self.radius
//                    startAngle:loadStart
//                      endAngle:loadCurre
//                     clockwise:YES];
    CGContextAddPath(ctx, [self CGPathFromPath:loadPath]);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //起始位置做圆滑处理
    CGContextSaveGState(ctx);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetFillColorWithColor(ctx, self.minimumTrackTintColor.CGColor);
    CGContextAddArc(ctx, self.circleStartPoint.x, self.circleStartPoint.y, self.circleBorderWidth / 2.0, -M_PI/3,  M_PI + M_PI/3, 0);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextRestoreGState(ctx);
    
//    //value
    NSBezierPath *circlePath = [NSBezierPath bezierPath];
    CGFloat originstart = -M_PI_2 * 5/6;
    CGFloat currentOrigin = originstart + 2/3 * M_PI * self.value;
    [circlePath appendBezierPathWithArcWithCenter:self.drawCenter radius:self.radius startAngle:originstart endAngle:currentOrigin clockwise:NO];

    CGContextSaveGState(ctx);
    CGContextSetLineWidth(ctx, self.circleBorderWidth);
    CGContextSetStrokeColorWithColor(ctx, self.minimumTrackTintColor.CGColor);
    CGContextAddPath(ctx, [self CGPathFromPath:circlePath]);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);
    
    /*
     * 计算移动点的位置
     * alpha = 移动点相对于起始点顺时针扫过的角度(弧度)
     * x = r * sin(alpha) + 圆心的x坐标, sin在0-PI之间为正，PI-2*PI之间为负
     * y 可以通过r * cos(alpha) + 圆心的y坐标来计算。
     * 不过我这里用了另外一个比较投机的方法，先算出亮点连线在y轴上投影的长度，然后根据移动点在y轴上相对于圆心的位置将这个绝对长度a和圆心y坐标相加减。
     */
//    self.value = 1/12.;
//    self.value = 0.065;
    if (self.value > 11/12. || self.value == 0) {
        self.value = 11/12.;
    }
    if (self.value < 1/12.) {
        self.value = 1/12.;
    }
    
    double alpha = self.value * 2 * M_PI;
    double x = self.radius * sin(alpha) + self.drawCenter.x;
    double y = sqrt(self.radius * self.radius - pow((self.drawCenter.x - x), 2)) + self.drawCenter.y;
    
    double a = y - self.drawCenter.y;
    if (self.value <= 0.25 || self.value > 0.75) {
        y = self.drawCenter.y - a;
    }
    NSLog(@"%f",self.value);
    self.lastPoint = CGPointMake(x, y);
    self.thumbView.zc_Center = self.lastPoint;
}

#pragma mark - UIControl methods
- (void)mouseDown:(NSEvent *)theEvent {
    
    [super mouseDown:theEvent];
    
    CGPoint starTouchPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];

    //如果点击点和上一次点击点的距离大于44，不做操作。
    double touchDist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.lastPoint];
    if (touchDist > 44) {
        self.interaction = NO;
        [self sendActionOn:NSEventMaskChangeMode];
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
        return;
    }
    //如果点击点和圆心的距离大于44，不做操作。
    //以上两步是用来限定滑块的点击范围，距离滑块太远不操作，距离圆心太远或太近不操作
    double dist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.drawCenter];
    if (fabs(dist - self.radius) > 44) {
        self.interaction = NO;
        [self sendActionOn:NSEventMaskChangeMode];
    //    [self sendActionsForControlEvents:UIControlEventValueChanged];
        return;
    }
    self.thumbView.zc_Center = self.lastPoint;
    //点击后滑块放大及动画
    CGFloat expandRate = self.thumbExpandRadius / self.thumbRadius;
    __weak typeof (self)weakSelf = self;
  
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        context.duration = 0.15;
//
//    } completionHandler:^{
//        weakSelf.thumbView.layer.affineTransform = CGAffineTransformMakeScale(1.0f * expandRate, 1.0f * expandRate);
//    }];
    [self moveHandlerWithPoint:starTouchPoint];
    [self sendActionOn:NSEventMaskChangeMode];
    [self sendAction:self.action to:self.target];
    
}
-(void)mouseDragged:(NSEvent *)theEvent {
    
    [super mouseDragged:theEvent];
    CGPoint starTouchPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    double touchDist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.lastPoint];
    if (touchDist > 44) {
        [self sendActionOn:NSEventMaskChangeMode];
        return;
    }
    double dist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.drawCenter];
    if (fabs(dist - self.radius) > 44) {
        [self sendActionOn:NSEventMaskChangeMode];
        return;
    }
    [self moveHandlerWithPoint:starTouchPoint];
    [self sendActionOn:NSEventMaskChangeMode];

    
    
}

- (void)mouseUp:(NSEvent *)event {
    
    [super mouseUp:event];
    self.thumbView.zc_Center = self.lastPoint;
 //  __weak typeof (self)weakSelf = self;
//   [UIView animateWithDuration:0.15
//                    animations:^{
//                        weakSelf.thumbView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
//                    }];
//    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
//        context.duration = 0.15;
//
//    } completionHandler:^{
//        weakSelf.thumbView.layer.affineTransform = CGAffineTransformMakeScale(1.0f, 1.0f);
//    }];
    CGPoint starTouchPoint = [self convertPoint:[event locationInWindow] fromView:nil];
   
   double touchDist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.lastPoint];
   if (touchDist > 44) {
       [self sendActionOn:NSEventMaskEndGesture];
       return;
   }
   double dist = [ZCircleSlider distanceBetweenPointA:starTouchPoint pointB:self.drawCenter];
   if (fabs(dist - self.radius) > 44) {
       [self sendActionOn:NSEventMaskEndGesture];
       return;
   }
   [self moveHandlerWithPoint:starTouchPoint];
   [self sendActionOn:NSEventMaskEndGesture];
    
}

- (void)moveHandlerWithPoint:(CGPoint)point {
    self.interaction = YES;
    CGFloat centerX = self.drawCenter.x;
    CGFloat centerY = self.drawCenter.y;
    
    CGFloat moveX = point.x;
    CGFloat moveY = point.y;
    
    if (!self.canRepeat) {
        //到300度，禁止移动到第一，二，三象限
        if (self.lockClockwise) {
            if ((moveX >= centerX && moveY <= centerY) ||
                (moveX >= centerX && moveY >= centerY) ||
                (moveX <= centerX && moveY >= centerY)) {
                return;
            }
        }
        
        //小于60度的时候，禁止移动到第二，三，四象限
        if (self.lockAntiClockwise) {
            if ((moveX <= centerX && moveY >= centerY) ||
                (moveX <= centerX && moveY <= centerY) ||
                (moveX >= centerX && moveY >= centerY)) {
                return;
            }
        }
    }
    
    double dist = sqrt(pow((moveX - centerY), 2) + pow(moveY - centerY, 2));
    if (fabs(dist - self.radius) > 44) {
        return;
    }
    /*
     * 计算移动点的坐标
     * sinAlpha = 亮点在x轴上投影的长度 ／ 距离
     * xT = r * sin(alpha) + 圆心的x坐标
     * yT 算法同上
     */
    double sinAlpha = (moveX - centerX) / dist;
    double xT = self.radius * sinAlpha + centerX;
    double yT = sqrt((self.radius * self.radius - (xT - centerX) * (xT - centerX))) + centerY;
    if (moveY < centerY) {
        yT = centerY - fabs(yT - centerY);
    }
    self.lastPoint = self.thumbView.zc_Center = CGPointMake(xT, yT);
   // self.lastPoint = CGPointMake(xT, yT);
    CGFloat angle = [ZCircleSlider calculateAngleWithRadius:self.radius
                                                     center:self.drawCenter
                                                startCenter:self.circleStartPoint
                                                  endCenter:self.lastPoint];
    if (angle >= 300) {
        //当当前角度大于等于300度时禁止移动到第一、二、三象限
        self.lockClockwise = YES;
    } else {
        self.lockClockwise = NO;
    }

    if (angle <= 60.0) {
        //当当前角度小于等于60度时，禁止移动到第二、三、四象限
        self.lockAntiClockwise = YES;
    } else {
        self.lockAntiClockwise = NO;
    }
    self.angle = angle;
    self.value = angle / 300;
}


/**
 计算圆上两点间的角度

 @param radius 半径
 @param center 圆心
 @param startCenter 起始点坐标
 @param endCenter 结束点坐标
 @return 圆上两点间的角度
 */
+ (CGFloat)calculateAngleWithRadius:(CGFloat)radius
                             center:(CGPoint)center
                        startCenter:(CGPoint)startCenter
                          endCenter:(CGPoint)endCenter {
    //a^2 = b^2 + c^2 - 2bccosA;
    CGFloat cosA = (2 * radius * radius - powf([ZCircleSlider distanceBetweenPointA:startCenter pointB:endCenter], 2)) / (2 * radius * radius);
    CGFloat angle = 180 / M_PI * acosf(cosA);
    if (startCenter.x > endCenter.x) {
        angle = 300 - angle;
    }
    return angle;
}

/**
 两点间的距离

 @param pointA 点A的坐标
 @param pointB 点B的坐标
 @return 两点间的距离
 */
+ (double)distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    double x = fabs(pointA.x - pointB.x);
    double y = fabs(pointA.y - pointB.y);
    return hypot(x, y);//hypot(x, y)函数为计算三角形的斜边长度
}

#pragma mark - KVO

//对angle添加KVO，有时候手势过快在continueTrackingWithTouch方法中不能及时限定转动，所以需要通过KVO对angle做实时监控
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    ZCircleSlider *circleSlider = (ZCircleSlider *)object;
    NSNumber *newAngle = [change valueForKey:@"new"];
    if ([keyPath isEqualToString:@"angle"]) {
        if (newAngle.doubleValue >= 300 ||
            circleSlider.angle >= 300) {
            self.lockClockwise = YES;
        } else {
            self.lockClockwise = NO;
        }
        
        if (newAngle.doubleValue <= 60 ||
            circleSlider.angle <= 60) {
            self.lockAntiClockwise = YES;
        } else {
            self.lockAntiClockwise = NO;
        }
    }
}
- (CGMutablePathRef)CGPathFromPath:(NSBezierPath *)path
{
    CGMutablePathRef cgPath = CGPathCreateMutable();
    NSInteger n = [path elementCount];
    
    for (NSInteger i = 0; i < n; i++) {
        NSPoint ps[3];
        switch ([path elementAtIndex:i associatedPoints:ps]) {
            case NSMoveToBezierPathElement: {
                CGPathMoveToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSLineToBezierPathElement: {
                CGPathAddLineToPoint(cgPath, NULL, ps[0].x, ps[0].y);
                break;
            }
            case NSCurveToBezierPathElement: {
                CGPathAddCurveToPoint(cgPath, NULL, ps[0].x, ps[0].y, ps[1].x, ps[1].y, ps[2].x, ps[2].y);
                break;
            }
            case NSClosePathBezierPathElement: {
                CGPathCloseSubpath(cgPath);
                break;
            }
            default: NSAssert(0, @"Invalid NSBezierPathElement");
        }
    }
    return cgPath;
}

- (BOOL)isFlipped {
    return NO;
}
@end
