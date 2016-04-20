//
//  ZDXMoveAndScrollView.m
//  MySomethingDemo
//
//  Created by ZDX on 15/10/16.
//  Copyright (c) 2015年 GroupFly. All rights reserved.
//

#import "ZDXMoveAndScrollView.h"

@interface ZDXMoveAndScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIView *moveView; // 滑块View
@property (strong, nonatomic) UIView *bottomLineView; // 底线
@property (strong, nonatomic) UIView *topLineView; // 顶线
@property (assign, nonatomic) CGFloat buttonWidth; // 按钮宽度
@property (assign, nonatomic) CGFloat buttonHeight; // 按钮高度

@property (strong, nonatomic) NSMutableArray *buttons; // 所有按钮
@property (strong, nonatomic) NSMutableArray *separationViews; // 所有分隔线

@property (strong, nonatomic) UIScrollView *scrollView; //包含所有页面
@property (strong, nonatomic) UIView *titleView; // 标题视图

@end

@implementation ZDXMoveAndScrollView
{
    BOOL _isDrag; //是否为拖拽滚动
    NSUInteger _currentIndex;   // 当前索引数
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _addSeparation = YES;
        self.backgroundColor = [UIColor clearColor];
        // 初始化所有组件，在drawRect:方法中更改frame
        // 1.添加标题视图
        [self setupTitleView];
        // 2.将所有的contentViews添加到ScrollView中
        [self setupContentViews];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttonsTitle contentViews:(NSArray *)contentViews {
    NSAssert(contentViews && contentViews.count, @"内容视图不能为空");
    NSAssert(buttonsTitle && buttonsTitle.count, @"标题不能为空");
    _buttonsTitle = buttonsTitle;
    _contentViews = contentViews;
    return [self initWithFrame:frame];
}

#pragma mark - GETTER
- (CGFloat)buttonTitleNormalFontSize {
    if (_buttonTitleNormalFontSize == 0) {
        _buttonTitleNormalFontSize = 14.0f;
    }
    return _buttonTitleNormalFontSize;
}

- (CGFloat)buttonTitleSelectedFontSize {
    if (_buttonTitleSelectedFontSize == 0) {
        _buttonTitleSelectedFontSize = 16.0f;
    }
    return _buttonTitleSelectedFontSize;
}

- (CGFloat)moveViewHeight {
    if (_moveViewHeight == 0) {
        _moveViewHeight = 2.0f;
    }
    return _moveViewHeight;
}

- (CGFloat)buttonHeight {
    _buttonHeight = self.titleViewHeight - self.moveViewHeight - 0.5f;
    return _buttonHeight;
}

- (CGFloat)titleViewHeight {
    if (_titleViewHeight == 0) {
        _titleViewHeight = 42.0f;
    }
    return _titleViewHeight;
}

- (UIColor *)buttonTitleNormalColor {
    if (!_buttonTitleNormalColor) {
        _buttonTitleNormalColor = [UIColor grayColor];
    }
    return _buttonTitleNormalColor;
}

- (UIColor *)buttonTitleSelectedColor {
    if (!_buttonTitleSelectedColor) {
        _buttonTitleSelectedColor = [UIColor redColor];
    }
    return _buttonTitleSelectedColor;
}

- (UIColor *)bottomLineColor {
    if (!_bottomLineColor) {
        _bottomLineColor = ZDX_DEFAULT_COLOR;
    }
    return _bottomLineColor;
}

- (UIColor *)topLineColor {
    if (!_topLineColor) {
        _topLineColor = ZDX_DEFAULT_COLOR;
    }
    return _topLineColor;
}

- (UIColor *)separationColor {
    if (!_separationColor) {
        _separationColor = ZDX_DEFAULT_COLOR;
    }
    return _separationColor;
}

- (NSMutableArray *)buttons {
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSMutableArray *)separationViews {
    if (!_separationViews) {
        _separationViews = [NSMutableArray array];
    }
    return _separationViews;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
    }
    return _titleView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

#pragma mark -  SETTER
- (void)setButtonsTitle:(NSArray *)buttonsTitle {
    NSAssert(buttonsTitle && buttonsTitle.count, @"标题不能为空");
    _buttonsTitle = buttonsTitle;
    [self setupTitleView];
}

- (void)setContentViews:(NSArray *)contentViews {
    NSAssert(contentViews && contentViews.count, @"内容视图不能为空");
    _contentViews = contentViews;
    [self setupContentViews];
}

#pragma mark - 按钮点击
- (void)chooseButtonAtIndex:(NSUInteger)index {
    NSAssert(index < _buttons.count, @"超出可选中范围");
    [self clickButton:_buttons[index]];
}

- (void)clickButton:(id)sender {
    UIButton *selectButton = sender;
    for (UIButton *button in _buttons) {
        button.selected = NO;
    }
    selectButton.selected = YES;
    //    [_moveView.layer addAnimation:[self moveX:0.3 X:[NSNumber numberWithFloat:selectButton.tag * _buttonWidth]] forKey:nil];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = _moveView.frame;
        frame.size.width = CGRectGetWidth([selectButton.currentAttributedTitle.string
                                           boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.buttonTitleSelectedFontSize]}
                                           context:nil]) + 5.0f;
        _moveView.frame = frame;
        
        CGPoint center = _moveView.center;
        center.x = selectButton.center.x;
        _moveView.center = center;
    } completion:^(BOOL finished) {
        if (!_isDrag) {
            [self.scrollView setContentOffset:CGPointMake(selectButton.tag * CGRectGetWidth(self.frame), 0) animated:YES];
        }
        _isDrag = NO;
        if (_currentIndex != selectButton.tag) {
            _currentIndex = selectButton.tag;
            if ([self.delegate respondsToSelector:@selector(moveAndScrollView:didSelectButtonIndex:)]) {
                [self.delegate moveAndScrollView:self didSelectButtonIndex:selectButton.tag];
            }
        }
    }];
}

// 移动滑块视图，time为时间，X为移动位置
-(CABasicAnimation *)moveX:(float)time X:(NSNumber *)x
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];// .y的话就向下移动
    animation.toValue = x;
    animation.duration = time;
    animation.removedOnCompletion = NO;//yes的话，又返回原位置了。
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

#pragma mark - 视图重绘
- (void)drawRect:(CGRect)rect {
    
    // 此方法只能用于更改颜色或Frame
    self.titleView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), self.titleViewHeight);
    self.buttonWidth = CGRectGetWidth(self.frame) / self.buttonsTitle.count;
    
    for (NSInteger i = 0; i < _buttons.count; i++) {
        
        UIButton *button = _buttons[i];
        button.frame = CGRectMake(i * self.buttonWidth, 0, self.buttonWidth, self.buttonHeight);
        
        // 设置按钮文字和颜色
        NSString *title = _buttonsTitle[i];
        NSMutableAttributedString *btnAttStrNor = [[NSMutableAttributedString alloc] initWithString:title];
        NSMutableAttributedString *btnAttStrSel = [[NSMutableAttributedString alloc] initWithString:title];
        
        [btnAttStrNor addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.buttonTitleNormalFontSize],
                                      NSForegroundColorAttributeName : self.buttonTitleNormalColor}
                              range:NSMakeRange(0, title.length)];
        
        [btnAttStrSel addAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.buttonTitleSelectedFontSize],
                                      NSForegroundColorAttributeName : self.buttonTitleSelectedColor}
                              range:NSMakeRange(0, title.length)];
        
        [button setAttributedTitle:btnAttStrNor forState:UIControlStateNormal];
        [button setAttributedTitle:btnAttStrSel forState:UIControlStateSelected];
        
        // 分隔线
        if (_addSeparation && i != 0) {
            UIView *separationView = _separationViews[i - 1];
            separationView.frame = CGRectMake(0, 0, 0.5f, self.titleViewHeight / 3.0f);
            // 分隔线中心位置
            separationView.center = CGPointMake(CGRectGetMinX(button.frame), CGRectGetHeight(self.titleView.frame) / 2);
            [separationView setBackgroundColor:self.separationColor];
        }
    }
    
    // 滑块
    CGRect frame = _moveView.frame;
    frame.origin.y = self.buttonHeight;
    frame.size.height = self.moveViewHeight;
    _moveView.frame = frame;
    [_moveView setBackgroundColor:_buttonTitleSelectedColor];
    CGPoint center = _moveView.center;
    for (UIButton *button in _buttons) {
        if (button.isSelected) {
            CGFloat moveViewWidth = CGRectGetWidth([_buttonsTitle[button.tag] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:self.buttonTitleSelectedFontSize]}
                                                                                           context:nil]) + 5.0f;
            frame.size.width = moveViewWidth;
            _moveView.frame = frame;
            center.x = button.center.x;
            _moveView.center = center;
            break;
        }
    }
    
    // 顶线
    self.topLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.titleView.frame), 0.5);
    [self.topLineView setBackgroundColor:self.topLineColor];
    
    // 底线
    self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.titleView.frame) - 1, CGRectGetWidth(self.titleView.frame), 0.5);
    [self.bottomLineView setBackgroundColor:self.bottomLineColor];
    
    // UIScrollView 属性
    self.scrollView.frame = CGRectMake(0, self.titleViewHeight, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.titleViewHeight);
    
    for (NSInteger i = 0; i < _contentViews.count; i++) {
        UIView *view = _contentViews[i];
        view.frame = CGRectMake(i * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.scrollView.frame));
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * _contentViews.count, CGRectGetHeight(self.scrollView.frame));
}

#pragma mark - 标题视图
- (void)setupTitleView {
    
    if (!self.buttonsTitle.count) return;
    
    // 顶线
    _topLineView = [[UIView alloc] init];
    [self.titleView addSubview:_topLineView];
    
    // 底线
    _bottomLineView = [[UIView alloc] init];
    [self.titleView addSubview:_bottomLineView];
    
    // 添加按钮
    for (NSInteger i = 0; i < self.buttonsTitle.count; i ++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            // 第一个按钮被选中
            button.selected = YES;
            _currentIndex = 0;
        }
        [self.titleView addSubview:button];
        [self.buttons addObject:button]; //将按钮添加到所有按钮数组中
        
        // 添加分隔线
        if (i != 0) {
            UIView *separationView = [[UIView alloc] init];
            [self.titleView addSubview:separationView];
            [self.separationViews addObject:separationView];//将分隔线添加到所有按钮数组中
        }
    }
    
    // 添加滑块
    _moveView = [[UIView alloc] initWithFrame:CGRectMake(0, self.buttonHeight, 0, self.moveViewHeight)];
    [self.titleView addSubview:_moveView];
    
    [self addSubview:self.titleView];
}

#pragma mark - 内容视图
- (void)setupContentViews {
    if (!self.contentViews.count) return;
    
    // UIScrollView 属性
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    for (UIView *view in _contentViews) {
        [self.scrollView addSubview:view];
    }
    [self addSubview:self.scrollView];
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSInteger tag = targetContentOffset->x / CGRectGetWidth(self.frame);
    UIButton *targetButton = nil;
    for (UIButton *button in _buttons) {
        if (button.tag == tag) {
            targetButton = button;
        }
    }
    _isDrag = YES;
    [self clickButton:targetButton];
}

@end
