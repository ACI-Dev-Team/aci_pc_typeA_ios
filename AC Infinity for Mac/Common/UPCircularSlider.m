//
//  EFCircularSlider.m
//  Awake
//
//  Created by Eliot Fowler on 12/3/13.
//  Copyright (c) 2013 Eliot Fowler. All rights reserved.
//

#import "UPCircularSlider.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>

#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#define FreamWidth  280
#define FreamHeight  80

@implementation UPCircularSlider {
    CGFloat radius;
    NSInteger _angle;
    
    NSMutableDictionary* labelsWithPercents;
    NSArray* labelsEvenSpacing;
    CGPoint _point;
}
- (id)initWithCoder:(NSCoder *)coder {
    
    
    if (self = [super initWithCoder:coder]) {
        // Defaults
        _maximumValue = 100.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
       // _currentAngle =0;
        //_money= 0;
        _lineWidth = 6;
        _unfilledColor = [NSColor lightGrayColor];
        _filledColor = [NSColor whiteColor];
       // _handleColor = _filledColor;
        _handleColor = [NSColor whiteColor];
        _labelFont = [NSFont systemFontOfSize:10.0f];
        _snapToLabels = NO;

        _labelColor = [NSColor redColor];
        
        _angle = 135;
        radius = self.frame.size.height/2 - _lineWidth/2 - 9;
//        [NSFont fontWithName:@"Avenir-Medium" size:60];
       //UIFont *font = [UIFont systemFontOfSize:10];
        self.label = [[NSTextField alloc]initWithFrame:CGRectMake(90,80, 100, 80)];
        self.label.alignment = NSTextAlignmentCenter;
        self.label.font = [NSFont boldSystemFontOfSize:60];
        self.label.font = [NSFont fontWithName:@"Avenir-Medium" size:60];
        self.label.textColor = [NSColor redColor];
        self.label.enabled = NO;
        self.label.drawsBackground = YES;
        self.label.bordered = NO;
        self.label.backgroundColor = NSColor.clearColor;
        [self addSubview:self.label];
        
        
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Defaults
        _maximumValue = 100.0f;
        _minimumValue = 0.0f;
        _currentValue = 0.0f;
       // _currentAngle =0;
        //_money= 0;
        _lineWidth = 5;
        _unfilledColor = [NSColor lightGrayColor];
        _filledColor = [NSColor whiteColor];
       // _handleColor = _filledColor;
        _handleColor = [NSColor whiteColor];
        _labelFont = [NSFont systemFontOfSize:10.0f];
        _snapToLabels = NO;

        _labelColor = [NSColor redColor];
        
        _angle = 135;
        radius = self.frame.size.height/2 - _lineWidth/2 - 9;
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor clearColor].CGColor;
       //UIFont *font = [UIFont systemFontOfSize:10];
        self.label = [[NSTextField alloc]initWithFrame:CGRectMake(90,80, 100, 80)];
        
        self.label.font = [NSFont boldSystemFontOfSize:60.];
        self.label.textColor = NSColor.whiteColor;
        self.label.enabled = NO;
        self.label.drawsBackground = NO;
       //self.label.bordered = NO;
        self.label.refusesFirstResponder = NO;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
        style.alignment = NSTextAlignmentCenter;
        
        self.label.attributedStringValue = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%zd",self.levelValue] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor],NSParagraphStyleAttributeName:style}];
        self.label.alignment = NSTextAlignmentCenter;
//        [self.label sizeToFit];
      //  self.label.backgroundColor = NSColor.clearColor;
        [self addSubview:self.label];
        
        
    
    }
    return self;
}
- (void)refreshLevel:(NSInteger)level {
    
    self.levelValue = level;
    
    [self moveLevel:level];
    
    
}
#pragma mark - drawing methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] CGContext];
    
    
    
    //Draw the unfilled circle
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, M_PI_4*3 , M_PI_4, 0);//0, M_PI *2, 0
    [_unfilledColor setStroke];
    
    CGContextSetLineWidth(ctx, 2);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);

    
    CGContextAddArc(ctx, self.frame.size.width/2  ,self.frame.size.height/2 ,radius,3*M_PI_4,6*M_PI_4-ToRad(_angle) , 0);//3*M_PI/2, 3*M_PI/2-ToRad(angle)
//    },
    
    //此处是设置颜色
    [_filledColor setStroke];
     // [[UIColor purpleColor] setStroke];
    CGContextSetLineWidth(ctx, _lineWidth);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    [self drawHandle:ctx];
    //The draggable part
    
}

-(void)drawHandle:(CGContextRef)ctx{///画滑块
    CGContextSaveGState(ctx);
    CGPoint handleCenter =  [self pointFromAngle: _angle];

    [[NSColor whiteColor]set];
        CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, 20, 20));
    //此处做了改动
    NSImage *image = [NSImage imageNamed:@"round"];
 
    [image drawAtPoint:CGPointMake((handleCenter.x),handleCenter.y) fromRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) operation:NSCompositingOperationColor fraction:1.];
   // [image drawAtPoint:CGPointMake((handleCenter.x),handleCenter.y)];

    CGContextRestoreGState(ctx);
}



#pragma mark - UIControl functions

- (void)mouseDown:(NSEvent *)event {


}
- (void)mouseDragged:(NSEvent *)event {
    
    if (self.canTouch == NO) {
        return;
    }
    
    
    CGPoint lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
  
    [self moveHandle:lastPoint];
//    [self sendAction:self.action to:self.target];
   // [self sendAction:self.action to:self.target];
    
}
- (void)mouseUp:(NSEvent *)event {

    if (self.canTouch == NO) {
        return;
    }
    
    CGPoint lastPoint = [self convertPoint:[event locationInWindow] fromView:nil];
 
    [self moveHandle:lastPoint];
//    [self sendAction:self.action to:self.target];

}


//
//-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
//    [super endTrackingWithTouch:touch withEvent:event];
//    
//    self.lastValue = _angle;
//}

-(void)moveHandle:(CGPoint)point {
    
    if (self.canTouch == NO) {
        return;
    }
    
    
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    int currentAngle = floor(AngleFromNorth(centerPoint, point, NO));
    NSInteger tempLevel = self.levelValue;
    if (currentAngle >= 135 && currentAngle < 149) {
        currentAngle = 135;
        self.levelValue = 0;
    }else if (currentAngle >= 149 && currentAngle < 162){
        currentAngle = 162;
        self.levelValue = 1;
    }else if (currentAngle >= 162 && currentAngle < 176){
        currentAngle = 162;
        self.levelValue = 1;
    }else if (currentAngle >= 176 && currentAngle < 189){
        currentAngle = 189;
        self.levelValue = 2;
    }else if (currentAngle >= 189 && currentAngle < 203){
        currentAngle = 189;
        self.levelValue = 2;
    }else if (currentAngle >= 203 && currentAngle < 216){
        currentAngle = 216;
        self.levelValue = 3;
    }else if (currentAngle >= 216 && currentAngle < 230){
        currentAngle = 216;
        self.levelValue = 3;
    }else if (currentAngle >= 230 && currentAngle < 243){
        currentAngle = 243;
        self.levelValue = 4;
    }else if (currentAngle >= 243 && currentAngle < 257){
        currentAngle = 243;
        self.levelValue = 4;
    }else if (currentAngle >= 257 && currentAngle < 270){
        currentAngle = 270;
        self.levelValue = 5;
    }else if (currentAngle >= 270 && currentAngle < 284){
        currentAngle = 270;
        self.levelValue = 5;
    }else if (currentAngle >= 284 && currentAngle < 297){
        currentAngle = 297;
        self.levelValue = 6;
    }else if (currentAngle >= 297 && currentAngle < 311){
        currentAngle = 297;
        self.levelValue = 6;
    }else if (currentAngle >= 311 && currentAngle < 324){
        currentAngle = 324;
        self.levelValue = 7;
    }else if (currentAngle >= 324 && currentAngle < 338){
        currentAngle = 324;
        self.levelValue = 7;
    }else if (currentAngle >= 338 && currentAngle < 351){
        currentAngle = 351;
        self.levelValue = 8;
    }else if ((currentAngle >= 351 && currentAngle < 360) || currentAngle < 5){
        currentAngle = 351;
        self.levelValue = 8;
    }else if (currentAngle >= 5 && currentAngle < 18){
        currentAngle = 18;
        self.levelValue = 9;
    }else if (currentAngle >= 18 && currentAngle < 32){
        currentAngle = 18;
        self.levelValue = 9;
    }else if (currentAngle >= 32 && currentAngle <= 45){
        currentAngle = 45;
        self.levelValue = 10;
    }
    if (currentAngle > 45 && currentAngle < 135) {
        return;
    }
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.alignment = NSTextAlignmentCenter;
    self.label.attributedStringValue = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%zd",self.levelValue] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor],NSParagraphStyleAttributeName:style}];

    _angle = 270 - currentAngle;
    
    
    _currentValue = [self valueFromAngle:270-currentAngle];
  //  NSLog(@"%f",_currentValue);
    
    _value=_angle;
    _fixedAngle = currentAngle;
    
    
    
    if(_value>223){
        _value=223+270-_angle;
    }else{
        _value=abs(134-_angle);
    }
    if (tempLevel != self.levelValue) {
        [self sendAction:self.action to:self.target];
    }
    
    [self setNeedsDisplay];
}
-(void)moveLevel:(NSInteger)level {

    int currentAngle = 135;
    
    if (level == 0) {
        currentAngle = 135;
    }else if (level == 1){
        currentAngle = 162;
    }else if (level == 2){
        currentAngle = 189;
    
    }else if (level == 3){
        currentAngle = 216;
  
    }else if (level == 4){
        currentAngle = 243;

    }else if (level == 5){
        currentAngle = 270;
      
    }else if (level == 6){
        currentAngle = 297;
      
    }else if (level == 7){
        currentAngle = 324;
    
    }else if (level == 8){
        currentAngle = 351;
       
    }else if (level == 9){
        currentAngle = 18;
    
    }else if (level == 10){
        currentAngle = 45;
     
    }
    if (currentAngle > 45 && currentAngle < 135) {
        return;
    }
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc]init];
    style.alignment = NSTextAlignmentCenter;
    self.label.attributedStringValue = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%zd",self.levelValue] attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor],NSParagraphStyleAttributeName:style}];
    _angle = 270 - currentAngle;
    
    
    _currentValue = [self valueFromAngle:270-currentAngle];
  //  NSLog(@"%f",_currentValue);
    
    _value=_angle;
    _fixedAngle = currentAngle;
    
    
    
    if(_value>223){
        _value=223+270-_angle;
    }else{
        _value=abs(134-_angle);
    }
    
    
    [self setNeedsDisplay];
}
#pragma mark - helper functions

-(CGPoint)pointFromAngle:(NSInteger)angleInt{
    
    //Define the Circle center
//    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - _lineWidth/2, self.frame.size.height/2 - _lineWidth/2);
        CGPoint centerPoint = CGPointMake(130, 130);
 
 //   CGPoint centerPoint = CGPointMake(self.frame.size.width/2 , self.frame.size.height/2);
    //Define The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt-90)));
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt-90)));
    
    NSLog(@"angle %@   %@",NSStringFromRect(self.frame),NSStringFromPoint(result));
    return result;
}

static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
//    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
//    v.x /= vmag;
//    v.y /= vmag;
    float result = 0 ;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}


-(float) valueFromAngle:(NSInteger)angle {
    if(angle < 0) {
        _currentValue = -angle;
    } else {
        _currentValue = 270 - angle + 90;
    }
    _fixedAngle = _currentValue;
    return (_currentValue*(_maximumValue - _minimumValue))/360.0f;
}
- (double)distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
    double x = fabs(pointA.x - pointB.x);
    double y = fabs(pointA.y - pointB.y);
    return hypot(x, y);//hypot(x, y)函数为计算三角形的斜边长度
}
- (CGFloat) widthOfString:(NSString *)string withFont:(NSFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

- (CGFloat) heightOfString:(NSString *)string withFont:(NSFont*)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].height;
}

#pragma mark - public methods
-(void)setInnerMarkingLabels:(NSArray*)labels{
    labelsEvenSpacing = labels;
    [self setNeedsDisplay];
}
- (BOOL)isFlipped {
    return YES;
}
@end
