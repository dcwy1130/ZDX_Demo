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

@end

@implementation ViewController
{
    NSUInteger tag;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
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
