//
//  ZDXPopupView.h
//  弹出视图
//
//  Created by 张德雄 on 16/4/15.
//  Copyright © 2016年 ShopNum1. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  用于显示应用中弹出视图的展示，包含左滑＼右滑＼下滑＼上滑＼淡入淡出\缩放等动画效果
 *  数据源用于获取要显示的视图
 */

// 动画效果
typedef NS_ENUM(NSInteger, ZDXPopupViewAnimationOptions) {
    // 关键帧动画
    ZDXPopupViewAnimationOptionsFadeInOut = 0,
    
    // 移动
    ZDXPopupViewAnimationOptionsFromLeft,
    ZDXPopupViewAnimationOptionsFromRight,
    ZDXPopupViewAnimationOptionsFromTop,
    ZDXPopupViewAnimationOptionsFromBottom,
    
    // 缩放
    ZDXPopupViewAnimationOptionsScaleFromLeftTop,
    ZDXPopupViewAnimationOptionsScaleFromRightTop,
    ZDXPopupViewAnimationOptionsScaleFromLeftBottom,
    ZDXPopupViewAnimationOptionsScaleFromRightBottom,
};

@class ZDXPopupView;

/// 数据源协议
@protocol ZDXPopupViewDataSource <NSObject>
@required
- (UIView *)viewForContentInPopupView:(ZDXPopupView *)popupVie;
@end

/// 代理协议
@protocol ZDXPopupViewDelegate <NSObject>
@optional
- (void)didSelectPopupViewBackgroud;
@end

@interface ZDXPopupView : UIView

@property (assign, nonatomic) CGFloat duration;     // 动画持续时间，默认为0.5s

@property (weak, nonatomic) id<ZDXPopupViewDataSource> dataSource;
@property (weak, nonatomic) id<ZDXPopupViewDelegate> delegate;

/// 动画效果
@property (assign, nonatomic) ZDXPopupViewAnimationOptions animationOptions;

/**
 *  显示弹出视图
 */
- (void)show;

/**
 *  隐藏弹出视图
 */
- (void)hide;

@end
