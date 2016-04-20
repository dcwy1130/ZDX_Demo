//
//  ZDXMoveView.h
//  2016.1.12   修正应用挂起再唤醒时，显示异常bug
//  2016.4.7    新增代码控制选中某一行
//  Created by Mac on 15/10/15.
//  Copyright (c) 2015年 ZDX All rights reserved.
//

#import <UIKit/UIKit.h>

// 分隔线，底部线，顶部线的默认颜色
#define ZDX_DEFAULT_COLOR [UIColor colorWithWhite:0.863 alpha:1.000]

@class ZDXMoveView;
@protocol ZDXMoveViewDelegate <NSObject>

@optional
/** 选中某个按钮代理方法 */
- (void)moveView:(ZDXMoveView *)moveView didSelectButtonIndex:(NSInteger)index;

@end

@interface ZDXMoveView : UIView

@property (copy, nonatomic) NSArray *buttonsTitle; // 所有按钮标题

@property (assign, nonatomic) CGFloat buttonTitleNormalFontSize; // default is 14.0
@property (assign, nonatomic) CGFloat moveViewHeight; // default is 2.0f

@property (strong, nonatomic) UIColor *buttonTitleNormalColor; // default is grayColor
@property (strong, nonatomic) UIColor *buttonTitleSelectedColor; // default is redColor
@property (strong, nonatomic) UIColor *separationColor;
@property (strong, nonatomic) UIColor *bottomLineColor;
@property (strong, nonatomic) UIColor *topLineColor;

@property (assign, nonatomic) BOOL addSeparation; // default is YES;

@property (weak, nonatomic) id<ZDXMoveViewDelegate> delegate;

/// 默认初始化方法
- (instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttonsTitle;

/// 代码控制选中某个索引
- (void)chooseButtonAtIndex:(NSUInteger)index;

@end
