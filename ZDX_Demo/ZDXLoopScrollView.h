//
//  ZDXLoopScrollView.h
//  循环滚动广告位视图
//
//  Created by Mac on 15/10/20.
//  Copyright (c) 2015年 ZDX. All rights reserved.
//

#define ZDX_MAIN_COLOR      [UIColor redColor]
#define ZDX_SCROLL_TIME     3.0

#import <UIKit/UIKit.h>

// PageControl 显示位置
typedef NS_ENUM(NSInteger, PageControlMode) {
    PageControlModeCenter,
    PageControlModeLeft,
    PageControlModeRight
};

@class ZDXLoopScrollView;

@protocol ZDXLoopScrollViewDataSource <NSObject>
@required
/** 返回展示广告个数 */
- (NSInteger)numberOfItemsInLoopScrollView:(ZDXLoopScrollView *)loopScrollView;
/** 返回展示广告视图 */
- (UIView *)loopScrollView:(ZDXLoopScrollView *)loopScrollView viewForItemAtIndex:(NSInteger)index;
@end

@protocol ZDXLoopScrollViewDelegate <NSObject>
@optional
/** 点击某张广告位事件 */
- (void)loopScrollView:(ZDXLoopScrollView *)loopScrollView didSelectItemAtIndex:(NSInteger)index;
@end

@interface ZDXLoopScrollView : UIView <UIScrollViewDelegate>

@property (strong, nonatomic) UIColor *pageIndicatorTintColor; // default is lightGrayColor
@property (strong, nonatomic) UIColor *currentPageIndicatorTintColor; // default is redColor
@property (assign, nonatomic) PageControlMode mode; // default is PageControlModeCenter

@property (weak, nonatomic) id<ZDXLoopScrollViewDataSource> dataSource;
@property (weak, nonatomic) id<ZDXLoopScrollViewDelegate> delegate;

/** 开始自动循环滚动 */
- (void)startAutoLoop;
/** 结束自动循环滚动 */
- (void)endAutoLoop;
/** 刷新数据 */
- (void)reloadData;

@end
