//
//  ZDXMoveAndScrollView.h
//  2016.1.12   修正应用挂起再唤醒时，显示异常bug
//  2016.4.7    新增代码控制选中某一行
//
//  Created by ZDX on 15/10/16.
//  Copyright (c) 2015年 GroupFly. All rights reserved.
//

#import <UIKit/UIKit.h>

// 分隔线，底部线，顶部线的默认颜色
#define ZDX_DEFAULT_COLOR [UIColor colorWithWhite:0.863 alpha:1.000]

@class ZDXMoveAndScrollView;
@protocol ZDXMoveAndScrollViewDelegate <NSObject>

@optional
/** 选中某个按钮代理方法 */
- (void)moveAndScrollView:(ZDXMoveAndScrollView *)moveAndScrollView didSelectButtonIndex:(NSInteger)index;

@end

@interface ZDXMoveAndScrollView : UIView

@property (copy, nonatomic) NSArray *buttonsTitle; // 所有按钮标题
@property (copy, nonatomic) NSArray *contentViews; //所有标题下的视图

@property (assign, nonatomic) CGFloat buttonTitleNormalFontSize; // default is 14.0
@property (assign, nonatomic) CGFloat buttonTitleSelectedFontSize; // default is 16.0
@property (assign, nonatomic) CGFloat moveViewHeight; // default is 2.0f
@property (assign, nonatomic) CGFloat titleViewHeight; // default is 42.0f, 标题视图高度

@property (strong, nonatomic) UIColor *buttonTitleNormalColor; // default is grayColor
@property (strong, nonatomic) UIColor *buttonTitleSelectedColor; // default is redColor
@property (strong, nonatomic) UIColor *separationColor;
@property (strong, nonatomic) UIColor *bottomLineColor;
@property (strong, nonatomic) UIColor *topLineColor;

@property (assign, nonatomic) BOOL addSeparation; // default is YES;

@property (weak, nonatomic) id<ZDXMoveAndScrollViewDelegate> delegate;

/// 默认初始化方法
- (instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttonsTitle contentViews:(NSArray *)contentViews;

/// 代码控制选中某个索引
- (void)chooseButtonAtIndex:(NSUInteger)index;

@end
