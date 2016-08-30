//
//  ZDXLoopScrollView.m
//  循环滚动广告位视图
//
//  Created by Mac on 15/10/20.
//  Copyright (c) 2015年 ZDX. All rights reserved.
//



#import "ZDXLoopScrollView.h"
#import "ZDXPageControl.h"

@interface ZDXLoopScrollView ()

@property (strong, nonatomic, readonly) UIScrollView *scrollView;
@property (strong, nonatomic, readonly) UIPageControl *pageControl;
@property (copy, nonatomic) NSArray *itemViews; // 当前UIScrollView中的3个View
@property (assign, nonatomic) NSInteger currentPage; // 当前页数
@property (assign, nonatomic) NSInteger totalPage; // 所有页数

@end

@implementation ZDXLoopScrollView
{
    NSTimer *_autoScrollTimer; //定时器
    UITapGestureRecognizer *_tap; // 单击手势
    CGFloat pageControlWidth;   // 分页指示器宽度
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:1.000 green:0.278 blue:1.000 alpha:1.000];
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // 初始化UIScrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * 3, CGRectGetHeight(self.bounds));
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds) * 2, 0);
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        
        // 初始化UIPageControl
        _pageControl = [[ZDXPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageControl];
        
        // 设置单击手势
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSelectItem:)];
        _tap.numberOfTapsRequired = 1;
        _tap.numberOfTouchesRequired = 1;
        [_scrollView addGestureRecognizer:_tap];
        
        _currentPage = 0;
//        _mode = PageControlModeCenter;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame pageControlMode:(PageControlMode)mode {
    _mode = mode;
    return [self initWithFrame:frame];
}

- (void)setDataSource:(id<ZDXLoopScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self reloadData];
}

- (UIColor *)pageIndicatorTintColor {
    if (!_pageIndicatorTintColor) {
        _pageIndicatorTintColor = [UIColor colorWithWhite:0.784 alpha:1.000];
    }
    return _pageIndicatorTintColor;
}

- (UIColor *)currentPageIndicatorTintColor {
    if (!_currentPageIndicatorTintColor) {
        _currentPageIndicatorTintColor = ZDX_MAIN_COLOR;
    }
    return _currentPageIndicatorTintColor;
}

// 刷新数据
- (void)reloadData {
//    NSLog(@"当前页: %d", _currentPage);
    // 获取总页数
    _totalPage = [_dataSource numberOfItemsInLoopScrollView:self];
    pageControlWidth = [_pageControl sizeForNumberOfPages:_totalPage].width;
    
    if (_totalPage <= 0) {
        // 无页面不展示
        return;
    } else if (_totalPage == 1) {
        // 展示页为1时，PageControl不显示，且ScrollView不滚动
        _pageControl.hidden = YES;
        _scrollView.scrollEnabled = NO;
        [self endAutoLoop];
    } else {
        _pageControl.hidden = NO;
        _scrollView.scrollEnabled = YES;
    }
    _pageControl.numberOfPages = _totalPage;
    [self setupData];
    
    CGRect frame = CGRectMake(0, CGRectGetMaxY(self.bounds) - 30.0f, pageControlWidth, 30.0f);
    switch (self.mode) {
        case PageControlModeCenter: {
            frame.origin.x = (CGRectGetWidth(self.bounds) - pageControlWidth) / 2.0f;
            break;
        }
        case PageControlModeLeft: {
            frame.origin.x = 20.0f;
            break;
        }
        case PageControlModeRight: {
            frame.origin.x = CGRectGetWidth(self.bounds) - pageControlWidth - 20;
            break;
        }
    }
    self.pageControl.frame = frame;
}

// 装载数据
- (void)setupData {
    _pageControl.currentPage = _currentPage;
    
    // 移除ScrollView所有子视图
    NSArray *subviews = _scrollView.subviews;
    if (subviews.count > 0) {
        // 从父视图移出
        [subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    // 获取DataSource中的当前展示视图
    _itemViews = [self fetchItemViewsWithCurrentPage:_currentPage];
    
    // 添加视图到ScrollView
    [self addSubviewsOfScrollView:_itemViews];
    [_scrollView setContentOffset:CGPointMake(CGRectGetWidth(self.bounds), 0)];
}

// 根据当前页数，获取当前显示所有视图
- (NSArray *)fetchItemViewsWithCurrentPage:(NSInteger)currentPage {
    NSInteger priorPage = currentPage-1 < 0 ? _totalPage-1 : currentPage-1; // <0 则为最后一页
    NSInteger nextPage = currentPage+1 == _totalPage ? 0 : currentPage+1; // 最大则为第一页
    
    NSMutableArray *itemViews = [NSMutableArray array];
    [itemViews addObject:[self.dataSource loopScrollView:self viewForItemAtIndex:priorPage]];
    [itemViews addObject:[_dataSource loopScrollView:self viewForItemAtIndex:currentPage]];
    [itemViews addObject:[_dataSource loopScrollView:self viewForItemAtIndex:nextPage]];
    return [itemViews copy];
}

// 将当前显示的所有视图数组添加到ScrollView中
- (void)addSubviewsOfScrollView:(NSArray *)itemViews {
    for (NSInteger i=0; i<itemViews.count; i++) {
        UIView *itemView = [itemViews objectAtIndex:i];
        itemView.frame = CGRectOffset(itemView.frame, CGRectGetMaxX(itemView.bounds) * i, 0);
        [_scrollView addSubview:itemView];
    }
}

// 开始循环滚动
- (void)startAutoLoop {
    // 设置定时器，循环滚动
    if (!_autoScrollTimer) {
        _autoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:ZDX_SCROLL_TIME target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
        // 将timer添加到运行循环模式：NSRunLoopCommonModes的运行循环模式（监听滚动模式）
        [[NSRunLoop currentRunLoop] addTimer:_autoScrollTimer forMode:NSRunLoopCommonModes];
        // 补充：
        // NSDefaultRunLoopMode:当我们执行其他滚动事件时，timer会默认暂时不监听，当滚动结束的时候会，继续监听。
        // NSRunLoopCommonModes:始终监听滚动事件
        // 当程序执行的时候，遇到cpu忙碌的时候，NSTimer会被放到一边不执行，就会造成该执行的事件不执行，会造成事件的叠加。
        // 所以说NSTimer通常会用来做一些有一定时间跨度的时间处理。
    }
}

// 结束循环滚动
- (void)endAutoLoop {
    // 关闭定时器
    if (_autoScrollTimer.isValid) {
        [_autoScrollTimer invalidate];
        _autoScrollTimer = nil;
    }
}

// 循环翻页
- (void)nextPage {
    // 滚动ScrollView
    CGPoint offset = _scrollView.contentOffset;
    offset.x += CGRectGetWidth(self.bounds);
    [_scrollView setContentOffset:offset animated:YES];
}

#pragma mark - UIScrollViewDelegate

// 滚动时触发
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 初始化时无数据源，则跳出
    NSInteger total = [self.dataSource numberOfItemsInLoopScrollView:self];    
    if (total == 0) {
        return;
    }
    
    float x = scrollView.contentOffset.x;
    // 前翻
    if (x <=0) {
        _currentPage = _currentPage-1 < 0 ? _totalPage-1 : _currentPage-1;
        [self setupData];
    }
    // 后翻
    if (x >= CGRectGetWidth(self.bounds) * 2.0) {
       _currentPage = _currentPage+1 == _totalPage ? 0 : _currentPage+1;
        [self setupData];
    }
}


// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endAutoLoop];
}

// 结束拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startAutoLoop];
}

// 代码驱动滚动动画结束代理
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    float x = scrollView.contentOffset.x;
    float width = CGRectGetWidth(self.bounds);
    float toX = 0.0f;
    
    if (x > 0) {
        toX = width;
    } else if (x > width) {
        toX = width * 2;
    } else if (x > width * 2) {
        toX = width * 3;
    }
    
    if (toX > 0.0f) {
        [_scrollView setContentOffset:CGPointMake(toX, 0)];
    }
}


#pragma mark - 点击广告事件
- (void)handleSelectItem:(UIGestureRecognizer *)sender {
    if ([_delegate respondsToSelector:@selector(loopScrollView:didSelectItemAtIndex:)]) {
        [_delegate loopScrollView:self didSelectItemAtIndex:_currentPage];
    }
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    _scrollView.frame = rect;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(rect) * 3, CGRectGetHeight(rect));
    _pageControl.currentPageIndicatorTintColor = self.currentPageIndicatorTintColor;
    _pageControl.pageIndicatorTintColor = self.pageIndicatorTintColor;
}

@end
