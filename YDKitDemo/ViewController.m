//
//  ViewController.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "ViewController.h"
#import "YDAvoidCrashKit.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *showLogBt = [UIButton buttonWithType:UIButtonTypeSystem];
    showLogBt.frame = CGRectMake(150, 200, 120, 30);
    [showLogBt setTitle:@"显示logDemo" forState:UIControlStateNormal];
    [showLogBt addTarget:self action:@selector(showLogVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showLogBt];
}

- (void)showLogVC {
    YDLogListViewController *vc = [[YDLogListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
