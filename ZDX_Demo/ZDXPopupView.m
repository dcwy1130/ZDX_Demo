//
//  ZDXPopupView.m
//  弹出视图
//
//  Created by 张德雄 on 16/4/15.
//  Copyright © 2016年 ShopNum1. All rights reserved.
//

#define ANIMATION_DURATION          0.5 // 动画时长
#define ANIMATION_DURATION_HIDE     0.02 // 背景隐藏时长

#import "ZDXPopupView.h"

@interface ZDXPopupView ()

@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) CAAnimation *showAnimation;
@property (strong, nonatomic) CAAnimation *dismissAnimation;

@end

@implementation ZDXPopupView
{
    CABasicAnimation *basicAnimation;
    CAKeyframeAnimation *keyFrameAnimation;
    
    CGPoint contentViewCenter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        basicAnimation = [CABasicAnimation animation];
        
        keyFrameAnimation = [CAKeyframeAnimation animation];
        keyFrameAnimation.keyPath = @"transform";
    }
    return self;
}

#pragma mark - SETTER
- (void)setDataSource:(id<ZDXPopupViewDataSource>)dataSource {
    NSAssert(dataSource, @"代理不能为空");
    _dataSource = dataSource;
    _contentView = [_dataSource viewForContentInPopupView:self];
    _contentView.userInteractionEnabled = YES;
    contentViewCenter = _contentView.center;
    [self addSubview:_contentView];
}

#pragma mark - GETTER
- (CGFloat)duration {
    if (!_duration) {
        _duration = ANIMATION_DURATION;
    }
    return _duration;
}

- (CAAnimation *)showAnimation {
    switch (_animationOptions) {
        case ZDXPopupViewAnimationOptionsFadeInOut: {
            keyFrameAnimation.duration = self.duration;
            keyFrameAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                                       [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8f, 0.8f, 1.0f)],
                                       [NSValue valueWithCATransform3D:CATransform3DIdentity]];
            keyFrameAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
            _showAnimation = keyFrameAnimation;
            break;
        }
        case ZDXPopupViewAnimationOptionsFromLeft: {
            _showAnimation = [self animationWithFromValue:@(-[UIScreen mainScreen].bounds.size.width)
                                                     toValue:@([UIScreen mainScreen].bounds.size.width)
                                                     keyPath:@"transform.translation.x"];
            break;
        }
        case ZDXPopupViewAnimationOptionsFromRight: {
            _showAnimation = [self animationWithFromValue:@([UIScreen mainScreen].bounds.size.width)
                                                     toValue:@(-[UIScreen mainScreen].bounds.size.width)
                                                     keyPath:@"transform.translation.x"];
            break;
        }
        case ZDXPopupViewAnimationOptionsFromTop: {
            _showAnimation = [self animationWithFromValue:@(-[UIScreen mainScreen].bounds.size.height)
                                                     toValue:@([UIScreen mainScreen].bounds.size.height)
                                                     keyPath:@"transform.translation.y"];
            break;
        }
        case ZDXPopupViewAnimationOptionsFromBottom: {
            _showAnimation = [self animationWithFromValue:@([UIScreen mainScreen].bounds.size.height)
                                                     toValue:@(-[UIScreen mainScreen].bounds.size.height)
                                                     keyPath:@"transform.translation.y"];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromLeftTop: {
            _showAnimation = [self animationWithFromValue:@(0.01)
                                                  toValue:@(1.0)
                                                  keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(0, 0)];
//            [_contentView.layer setPosition:CGPointMake(50, 150)];
            [_contentView.layer setPosition:CGPointMake(contentViewCenter.x - CGRectGetWidth(_contentView.frame) / 2, contentViewCenter.y - CGRectGetHeight(_contentView.frame) / 2)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromRightTop: {
            _showAnimation = [self animationWithFromValue:@(0.01)
                                                  toValue:@(1.0)
                                                  keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(1, 0)];
            //            [_contentView.layer setPosition:CGPointMake(50, 150)];
            [_contentView.layer setPosition:CGPointMake(contentViewCenter.x + CGRectGetWidth(_contentView.frame) / 2, contentViewCenter.y - CGRectGetHeight(_contentView.frame) / 2)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromLeftBottom: {
            _showAnimation = [self animationWithFromValue:@(0.01)
                                                  toValue:@(1.0)
                                                  keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(0, 1)];
            //            [_contentView.layer setPosition:CGPointMake(50, 150)];
            [_contentView.layer setPosition:CGPointMake(contentViewCenter.x - CGRectGetWidth(_contentView.frame) / 2, contentViewCenter.y + CGRectGetHeight(_contentView.frame) / 2)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromRightBottom: {
            _showAnimation = [self animationWithFromValue:@(0.01)
                                                  toValue:@(1.0)
                                                  keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(1, 1)];
            //            [_contentView.layer setPosition:CGPointMake(250, 350)];
            [_contentView.layer setPosition:CGPointMake(contentViewCenter.x + CGRectGetWidth(_contentView.frame) / 2, contentViewCenter.y + CGRectGetHeight(_contentView.frame) / 2)];
            break;
        }
    }
    return _showAnimation;
}

- (CAAnimation *)dismissAnimation {
    switch (_animationOptions) {
        case ZDXPopupViewAnimationOptionsFadeInOut: {
            keyFrameAnimation.duration = self.duration;
            keyFrameAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8f, 0.8f, 1.0f)],
                                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2f, 1.2f, 1.0f)],
                                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)]];
            keyFrameAnimation.keyTimes = @[@0.20f, @0.60f, @1.0f];
            _dismissAnimation = keyFrameAnimation;
            break;
        }
        case ZDXPopupViewAnimationOptionsFromLeft: {
            _dismissAnimation = [self animationWithFromValue:nil
                                                     toValue:@(-[UIScreen mainScreen].bounds.size.width)
                                                     keyPath:@"transform.translation.x"];
            break;
        }
        case ZDXPopupViewAnimationOptionsFromRight: {
            _dismissAnimation = [self animationWithFromValue:nil
                                                     toValue:@([UIScreen mainScreen].bounds.size.width)
                                                     keyPath:@"transform.translation.x"];
            break;
        }
        case ZDXPopupViewAnimationOptionsFromTop: {
            _dismissAnimation = [self animationWithFromValue:nil
                                                     toValue:@(-[UIScreen mainScreen].bounds.size.height)
                                                     keyPath:@"transform.translation.y"];
            
            break;
        }
        case ZDXPopupViewAnimationOptionsFromBottom: {
            _dismissAnimation = [self animationWithFromValue:nil
                                                     toValue:@([UIScreen mainScreen].bounds.size.height)
                                                     keyPath:@"transform.translation.y"];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromLeftTop: {
            _dismissAnimation = [self animationWithFromValue:@(1.0)
                                                     toValue:@(0.01)
                                                     keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(0, 0)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromRightTop: {
            _dismissAnimation = [self animationWithFromValue:@(1.0)
                                                     toValue:@(0.01)
                                                     keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(1, 0)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromLeftBottom: {
            _dismissAnimation = [self animationWithFromValue:@(1.0)
                                                     toValue:@(0.01)
                                                     keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(0, 1)];
            break;
        }
        case ZDXPopupViewAnimationOptionsScaleFromRightBottom: {
            _dismissAnimation = [self animationWithFromValue:@(1.0)
                                                     toValue:@(0.01)
                                                     keyPath:@"transform.scale"];
            [_contentView.layer setAnchorPoint:CGPointMake(1, 1)];
            break;
        }
    }
    return _dismissAnimation;
}

#pragma mark - return CAAnimation
- (CAAnimation *)animationWithFromValue:(NSNumber *)fromValue toValue:(NSNumber *)toValue keyPath:(NSString *)keyPath{
    basicAnimation.keyPath = keyPath;
    
    // 缩放效果value
    if ([keyPath isEqualToString:@"transform.scale"]) {
        basicAnimation.byValue = nil;
        basicAnimation.fromValue = fromValue;
        basicAnimation.toValue = toValue;
    } else {
        // 平移效果value
        basicAnimation.toValue = nil;
        if (fromValue) {
            basicAnimation.fromValue = fromValue;
            basicAnimation.byValue = toValue;
        } else {
            basicAnimation.fromValue = @(0);
            basicAnimation.byValue = toValue;
        }
    }
    basicAnimation.duration = self.duration;
//    basicAnimation.removedOnCompletion = YES;//yes的话，又返回原位置了。
//    animation.fillMode = kCAFillModeForwards;
    return basicAnimation;
}

// 展示
- (void)show {
    // 初始状况
    [_contentView.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [_contentView.layer setPosition:contentViewCenter];
//    [_contentView.layer setTransform:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)];
//    [_contentView.layer setContentsScale:1.0];
    
    self.alpha = 1.0;
    if ([self.dataSource respondsToSelector:@selector(viewForContentInPopupView:)]) {
        [[[[UIApplication sharedApplication].keyWindow subviews] firstObject] addSubview:self];
        [self.contentView.layer addAnimation:self.showAnimation forKey:nil];
    }
}

// 消失
- (void)hide {
    [self.contentView.layer addAnimation:self.dismissAnimation forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.duration - 0.1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:ANIMATION_DURATION_HIDE animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    });
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(didSelectPopupViewBackgroud)]) {
        [self.delegate didSelectPopupViewBackgroud];
    } else {
        [self hide];
    }
}


@end
