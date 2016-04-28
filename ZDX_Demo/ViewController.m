//
//  ViewController.m
//  ZDX_Demo
//
//  Created by 张德雄 on 16/4/20.
//  Copyright © 2016年 GroupFly. All rights reserved.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;

@end

@implementation ViewController
{
    NSUInteger tag;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.noticeLabel.text = @"特惠大战，即奖打响！！！即日起，全场满100-20，满100-20，满100-20，满100-20。新用户立减15元！！！";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(updateNotice) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
}

- (void)updateNotice {
    CGRect frame = _noticeLabel.frame;
    frame.origin.x --;
    CGFloat textWidth = CGRectGetWidth(self.noticeLabel.frame);
    if (frame.origin.x == -textWidth) {
        frame.origin.x = [UIScreen mainScreen].bounds.size.width;
    }
    _noticeLabel.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender {
    tag = sender.tag - 1000;
    [self performSegueWithIdentifier:@"kSeguePush" sender:self];
}


#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     DemoViewController *demoVC = [segue destinationViewController];
     demoVC.type = tag;     
 }



@end
