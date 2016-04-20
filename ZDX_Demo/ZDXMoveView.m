//
//  ZDXMoveView.m
//
//  Created by Mac on 15/10/15.
//  Copyright (c) 2015年 ZDX All rights reserved.
//

#import "ZDXMoveView.h"

@interface ZDXMoveView ()

@property (strong, nonatomic) UIView *moveView; // 滑块View
@property (strong, nonatomic) UIView *bottomLineView; // 底线
@property (strong, nonatomic) UIView *topLineView; // 顶线
@property (assign, nonatomic) CGFloat buttonWidth; // 按钮宽度
@property (assign, nonatomic) CGFloat buttonHeight; // 按钮高度
@property (strong, nonatomic) NSMutableArray *buttons; // 所有按钮
@property (strong, nonatomic) NSMutableArray *separationViews; // 所有分隔线

@end

@implementation ZDXMoveView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _addSeparation = YES;
        [self setupMoveView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame buttons:(NSArray *)buttonsTitle {
    NSAssert(buttonsTitle && buttonsTitle.count, @"标题不能为空");
    _buttonsTitle = buttonsTitle;
    return [self initWithFrame:frame];
}

#pragma mark - GETTER

- (CGFloat)buttonTitleNormalFontSize {
    if (_buttonTitleNormalFontSize == 0) {
        _buttonTitleNormalFontSize = 14.0f;
    }
    return _buttonTitleNormalFontSize;
}

- (CGFloat)moveViewHeight {
    if (_moveViewHeight == 0) {
        _moveViewHeight = 2.0f;
    }
    return _moveViewHeight;
}

- (CGFloat)buttonHeight {
    _buttonHeight = CGRectGetHeight(self.frame) - self.moveViewHeight - 0.5;
    return _buttonHeight;
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

#pragma mark -  SETTER
- (void)setButtonsTitle:(NSArray *)buttonsTitle {
    NSAssert(buttonsTitle && buttonsTitle.count, @"标题不能为空");
    _buttonsTitle = buttonsTitle;
    [self setupMoveView];
}

// 配置界面
- (void)setupMoveView {
    if (self.buttonsTitle && self.buttonsTitle.count >= 2) {
        if (self.buttons.count == 0) {
            self.buttonWidth = CGRectGetWidth(self.frame) / self.buttonsTitle.count;
            for (NSInteger index = 0; index < self.buttonsTitle.count; index ++) {
                UIButton *button = [[UIButton alloc] init];
                // 设置按钮文字和颜色
                [button setTitle:_buttonsTitle[index] forState:UIControlStateNormal];
                
                button.tag = index;
                [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
                if (index == 0) {
                    // 第一个按钮被选中
                    button.selected = YES;
                }
                [self addSubview:button];
                [self.buttons addObject:button]; //将按钮添加到所有按钮数组中
                // 添加分隔线
                if (index != 0) {
                    UIView *separationView = [[UIView alloc] init];
                    [self addSubview:separationView];
                    [self.separationViews addObject:separationView];//将分隔线添加到所有按钮数组中
                }
            }
            
            // 顶线
            self.topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5)];
            [self addSubview:self.topLineView];
            
            // 底线
            self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5)];
            [self addSubview:self.bottomLineView];
            
            // 添加滑块
            self.moveView = [[UIView alloc] initWithFrame:CGRectMake(0, self.buttonHeight, self.buttonWidth, self.moveViewHeight)];
            [self addSubview:self.moveView];
        }
    }
}


#pragma mark - 按钮点击
- (void)chooseButtonAtIndex:(NSUInteger)index {
    NSAssert(index < _buttons.count, @"超出可选中范围");
    [self clickButton:_buttons[index]];
}

- (void)clickButton:(UIButton *)sender {
    UIButton *selectButton = sender;
    for (UIButton *button in _buttons) {
        button.selected = NO;
    }
    selectButton.selected = YES;
    
    [UIView animateWithDuration:0.3f animations:^{
        CGPoint center = _moveView.center;
        center.x = selectButton.center.x;
        _moveView.center = center;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(moveView:didSelectButtonIndex:)]) {
            [self.delegate moveView:self didSelectButtonIndex:selectButton.tag];
        }
    }];
}

// 移动滑块视图，time为时间，X为移动位置
-(CABasicAnimation *)moveX:(float)time X:(NSNumber *)x {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];// .y的话就向下移动
    animation.toValue = x;
    animation.duration = time;
    animation.removedOnCompletion = NO;//yes的话，又返回原位置了。
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

// 重写父类方法
- (void)drawRect:(CGRect)rect {
    self.frame = rect;
    for (int i = 0; i < self.buttons.count; i++) {
        // 设置按钮文字和颜色
        UIButton *btn = self.buttons[i];
        btn.frame = CGRectMake(i * self.buttonWidth, 0, self.buttonWidth, self.buttonHeight);
        [btn setTitleColor:self.buttonTitleNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.buttonTitleSelectedColor forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:self.buttonTitleNormalFontSize];
        
        // 分隔线
        if (_addSeparation && i != 0) {
            UIView *separationView = _separationViews[i - 1];
            separationView.frame = CGRectMake(0, 0, 0.5f, CGRectGetHeight(self.frame) / 3.0f);
            // 分隔线中心位置
            separationView.center = CGPointMake(CGRectGetMinX(btn.frame), CGRectGetHeight(self.frame) / 2);
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
            center.x = button.center.x;
            _moveView.center = center;
            break;
        }
    }
    
    // 顶线
    self.topLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5);
    [self.topLineView setBackgroundColor:self.topLineColor];
    
    // 底线
    self.bottomLineView.frame = CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5);
    [self.bottomLineView setBackgroundColor:self.bottomLineColor];
    
}

@end
