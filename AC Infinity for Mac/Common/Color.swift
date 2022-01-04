
//
//  Color.swift
//  ACController
//
//  Created by Tony on 2019/9/9.
//  Copyright © 2019 Tony. All rights reserved.
//

import Cocoa

class Color: NSObject {
    
     ///默认背景颜色
    static let defaultBackgroundColor = ColorHelper.colorWithHexString(hex: "#0d0d0d")
    static let cellBackColor = ColorHelper.colorWithHexString(hex: "#242425")
    static let tabShadowColor = ColorHelper.colorWithHexString(hex: "#5d5d5d")
    
    ///蓝牙雷达颜色
    static let radarColor = ColorHelper.colorWithHexString(hex: "#128BEC")
    
    //断开连接的红色
    static let redColor = ColorHelper.colorWithHexString(hex: "#FF2D55")
    
    ///渐变色123
    static let gradientColor1 = ColorHelper.colorWithHexString(hex: "#29C9F7")
    static let gradientColor2 = ColorHelper.colorWithHexString(hex: "#1DA9F1")
    static let gradientColor3 = ColorHelper.colorWithHexString(hex: "#128BEC")
    
    ///圆盘中间的渐变色
    static let circleGradientColor1 = ColorHelper.colorWithHexString(hex: "#21409A")
    static let circleGradientColor2 = ColorHelper.colorWithHexString(hex: "#00B8EC")
    
    ///选项title
    static let subTitleColor = ColorHelper.colorWithHexString(hex: "#8F8E94")
    ///cancel
    static let cancelColor = ColorHelper.colorWithHexString(hex: "#0076FF")
    ///Delete
    static let deleteColor = ColorHelper.colorWithHexString(hex: "#FF3B30")
    ///line color
    static let lineColor = ColorHelper.colorWithHexString(hex: "#EDEDEE")
    ///控制面板页面数字颜色
    static let blueColor = ColorHelper.colorWithHexString(hex: "#15BAFF")
    ///灰色
    static let grayColor = ColorHelper.colorWithHexString(hex: "#656565")
    ///黄色
    static let brownColor = ColorHelper.colorWithHexString(hex: "#FF7800")
    ///292929
    static let color_292929 = ColorHelper.colorWithHexString(hex: "#292929")
    
    static let color_f1f1f1 = ColorHelper.colorWithHexString(hex: "#f1f1f1")
    
    static let color_1c1c1e = ColorHelper.colorWithHexString(hex: "#1c1c1e")
    
    static let color_545458 = ColorHelper.colorWithHexString(hex: "#545458")
    
    static let color_e5e5ea = ColorHelper.colorWithHexString(hex: "#E5E5EA")
    
    static let color_a0a0a0 = ColorHelper.colorWithHexString(hex: "#a0a0a0")
    
    static let color_707070 = ColorHelper.colorWithHexString(hex: "#707070")
}
