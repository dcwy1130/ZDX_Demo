//
//  DemoViewController.m
//  ZDX_Demo
//
//  Created by 张德雄 on 16/4/20.
//  Copyright © 2016年 GroupFly. All rights reserved.
//

#import "DemoViewController.h"

#import <objc/runtime.h>

#import "ZDXMoveView.h"
#import "ZDXMoveAndScrollView.h"
#import "ZDXPopupView.h"
#import "ZDXLoopScrollView.h"

@interface DemoViewController ()<UITableViewDataSource, UITableViewDelegate, ZDXMoveViewDelegate, ZDXMoveAndScrollViewDelegate, ZDXPopupViewDataSource, ZDXLoopScrollViewDataSource, ZDXLoopScrollViewDelegate>

@property (strong, nonatomic) ZDXPopupView *popView;
@property (nonatomic,strong) ZDXLoopScrollView *loopScrollView;

@property (copy, nonatomic) NSArray *titles;

@end

@implementation DemoViewController



#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];    
    self.navigationController.navigationBar.translucent = NO;
    
    self.titles = @[@"惊喜", @"左滑", @"右滑", @"上滑", @"下滑", @"左上缩放", @"右上缩放", @"左下缩放", @"右下缩放"];
    
    SEL selector = NULL;
    switch (self.type) {
        case 1:
            self.title = @"移动视图";
            selector = @selector(test1);
            break;
        case 2:
            self.title = @"移动滚动视图";
            selector = @selector(test2);
            break;
        case 3:
            self.title = @"弹出视图";
            selector = @selector(test3);
            break;
        case 4:
            self.title = @"广告位滚动视图";
            selector = @selector(test4);
            break;
    }
    [self performSelector:selector];
//    Method originalMethod = class_getInstanceMethod([self class], @selector(test));
//    Method swizzledMethod = class_getInstanceMethod([self class], selector);
//    method_exchangeImplementations(originalMethod, swizzledMethod);
    [self performSelector:@selector(test) withObject:self afterDelay:3.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.loopScrollView startAutoLoop];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.loopScrollView endAutoLoop];
}

#pragma mark - Test
// 截屏，带导航栏
- (void)test {
    CGSize size = self.navigationController.view.frame.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    CGRect rec = self.navigationController.view.frame;
    [self.navigationController.view drawViewHierarchyInRect:rec afterScreenUpdates:YES];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData * data = UIImagePNGRepresentation(image);

    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filename = [[path objectAtIndex:0] stringByAppendingPathComponent:@"Screen_Image.png"];
    [data writeToFile:filename atomically:YES];
    
//    CGRect rect = self.view.frame;
//    UIGraphicsBeginImageContext(rect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
////    [view.layer renderInContext:context];
////    [self.navigationController.view.layer renderInContext:context];
//    [self.view.window.layer renderInContext:context];
//    
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    NSData * data = UIImagePNGRepresentation(image);
//
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *filename = [[path objectAtIndex:0] stringByAppendingPathComponent:@"Screen_Image.png"];
//    [data writeToFile:filename atomically:YES];
}

- (void)test1 {
    ZDXMoveView *moveView = [[ZDXMoveView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44) buttons:@[@"热卖", @"精品", @"促销", @"精品", @"促销"]];
    moveView.delegate = self;
    [self.view addSubview:moveView]; // 添加到主视图
    
    // 代码控制选中某一行
//    [moveView chooseButtonAtIndex:2];
}

- (void)test2 {
    NSMutableArray *tempAry = [NSMutableArray array];
    for (int i = 0; i < 5; i ++) {
        UITableView *tableView = [[UITableView alloc] init];
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CELL"];
        tableView.dataSource = self;
        tableView.delegate = self;
        [tempAry addObject:tableView];
    }
    ZDXMoveAndScrollView *moveAndScrollView = [[ZDXMoveAndScrollView alloc] initWithFrame:self.view.bounds
                                                                                  buttons:@[@"全部", @"待付款", @"待发货", @"待收货", @"待评价"]
                                                                             contentViews:tempAry];
    
    moveAndScrollView.delegate = self;
    [self.view addSubview:moveAndScrollView];
    // 代表控制选中某行
//    [moveAndScrollView chooseButtonAtIndex:2];
}

- (void)test3 {
    [self test2];
    self.popView = [[ZDXPopupView alloc] initWithFrame:self.view.bounds animationOption:ZDXPopupViewAnimationOptionFromBottom];
    self.popView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
    self.popView.dataSource = self;
}

- (void)test4 {
    self.loopScrollView = [[ZDXLoopScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) pageControlMode:PageControlModeRight];
//    self.loopScrollView.mode = PageControlModeRight;
    self.loopScrollView.delegate = self;
    self.loopScrollView.dataSource = self;
    [self.view addSubview:self.loopScrollView];
}

#pragma mark - UITableView Data Source And Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.popView.animationOption = indexPath.row % 9;
    [self.popView show];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - PopupView Data Source
- (UIView *)viewForContentInPopupView:(ZDXPopupView *)popupVie {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    v.backgroundColor = [UIColor yellowColor];
    //    [v addTarget:self action:@selector(test3) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    b1.backgroundColor = [UIColor greenColor];
    [b1 setTitle:@"Look" forState:UIControlStateNormal];
    b1.tag = 1000;
    [v addSubview:b1];
    [b1 addTarget:self action:@selector(test5:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 200, 100)];
    b2.backgroundColor = [UIColor redColor];
    [b2 setTitle:@"Here" forState:UIControlStateNormal];
    b2.tag = 1001;
    [v addSubview:b2];
    [b2 addTarget:self action:@selector(test5:) forControlEvents:UIControlEventTouchUpInside];
    
    return v;
}

- (void)test5:(UIButton *)btn {
    NSString *message = [NSString stringWithFormat:@"你点了%@按钮", btn.tag - 1000 ? @"红色" : @"绿色"];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - LoopScrollView DataSource And Delegate
- (NSInteger)numberOfItemsInLoopScrollView:(ZDXLoopScrollView *)loopScrollView {
    return 8;
}

- (UIView *)loopScrollView:(ZDXLoopScrollView *)loopScrollView viewForItemAtIndex:(NSInteger)index {
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:loopScrollView.bounds];
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld", (long)index]];
    return imageView;
}

- (void)loopScrollView:(ZDXLoopScrollView *)loopScrollView didSelectItemAtIndex:(NSInteger)index {
    NSString *message = [NSString stringWithFormat:@"点击了第%ld个", index + 1];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



@end
