//
//  ZDXPageControl.m
//  MySomethingDemo
//
//  Created by Mac on 15/10/21.
//  Copyright (c) 2015年 ZDX. All rights reserved.
//

#import "ZDXPageControl.h"

@implementation ZDXPageControl

- (void) setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        CGSize size;
        // 大小
        size.height = 10.0;
        size.width = 10.0;
        [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,
                                     size.width,size.height)];
        subview.layer.borderColor = [UIColor whiteColor].CGColor;
        subview.layer.cornerRadius = size.width * 0.5;
        subview.layer.borderWidth = 1.0;
        subview.clipsToBounds = YES;
    }];
}



@end
