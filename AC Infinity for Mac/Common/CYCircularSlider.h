//
//  CYCircularSlider.h
//  CYCircularSlider
//
//  Created by user on 2018/3/23.
//  Copyright © 2018年 com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol senderValueChangeDelegate <NSObject>

-(void)senderVlueWithNum:(int)num;

@end

@interface CYCircularSlider : NSControl

/**
 实现按钮颜色
 */
@property (nonatomic, strong) NSColor* filledColor;

/**
 空心按钮颜色
 */
@property (nonatomic, strong) NSColor* unfilledColor;


/**
 最小值
 */
@property (nonatomic) float minimumValue;
//
/**
 最大值
 */
@property (nonatomic) float maximumValue;
//当前值
@property (nonatomic) float currentValue;

/**
 圈边宽度
 */
@property (nonatomic) int lineWidth;


@property (nonatomic, strong) NSColor* handleColor;


@property (nonatomic,weak) id<senderValueChangeDelegate> delegate;


-(void)setAngel:(int)num;

-(void)setAddAngel;

-(void)setMovAngel;


@end
