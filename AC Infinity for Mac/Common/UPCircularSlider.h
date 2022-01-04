//
//  EFCircularSlider.h
//  Awake
//
//  Created by Eliot Fowler on 12/3/13.
//  Copyright (c) 2013 Eliot Fowler. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface  UPCircularSlider: NSControl

//typedef enum : NSUInteger {
//    semiTransparentWhiteCircle,
//    semiTransparentBlackCircle,
//    doubleCircleWithOpenCenter,
//    doubleCircleWithClosedCenter,
//    bigCircle
//} HandleType;

@property (nonatomic,assign) CGFloat minimumValue;
@property (nonatomic,assign) CGFloat maximumValue;
@property (nonatomic,assign) CGFloat currentValue;
@property(nonatomic,assign) NSInteger money;
@property(nonatomic,assign) NSInteger number;
@property(nonatomic,assign) NSInteger value;
@property(nonatomic,assign) NSInteger lastValue;
@property (nonatomic,assign) NSInteger lineWidth;
@property (nonatomic, strong) NSColor* filledColor;
@property (nonatomic, strong) NSColor* unfilledColor;
//@property(nonatomic)int angle;
@property (nonatomic, strong) NSColor* handleColor;
//@property (nonatomic) HandleType handleType;
@property (nonatomic, strong) NSTextField* label;
@property (nonatomic, strong) NSFont* labelFont;
@property (nonatomic, strong) NSColor* labelColor;
@property (nonatomic) BOOL snapToLabels;

@property (nonatomic,assign) NSInteger levelValue;

@property (nonatomic,assign) NSInteger fixedAngle;

@property (nonatomic,assign) BOOL canTouch;


-(void)setInnerMarkingLabels:(NSArray*)labels;

- (void)refreshLevel:(NSInteger)level;

@end
