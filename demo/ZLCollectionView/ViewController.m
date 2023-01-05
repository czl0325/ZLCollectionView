//
//  ViewController.m
//  ZLCollectionView
//
//  Created by zhaoliang chen on 2017/6/22.
//  Copyright © 2017年 zhaoliang chen. All rights reserved.
//

#import "ViewController.h"
#import "VerticalViewController.h"
#import "HorzontalViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTranslucent:NO];
    //UIColorFromRGB(0x71b8ff)
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:143.0/255 green:188.0/255 blue:37.0/255 alpha:1.0]];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //设置导航栏后退按钮颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //去掉导航栏后退按钮的文字
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:0.001],NSForegroundColorAttributeName:[UIColor clearColor]} forState:UIControlStateNormal];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],NSForegroundColorAttributeName : [UIColor colorWithRed:113.0/255 green:184.0/255 blue:1.0 alpha:1.0]} forState:UIControlStateSelected];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12],NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateNormal];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
    [[UITabBar appearance] setTranslucent:NO];
    
    UINavigationController *nav1 = [[UINavigationController alloc]initWithRootViewController:[VerticalViewController new]];
    
    UINavigationController *nav2 = [[UINavigationController alloc]initWithRootViewController:[HorzontalViewController new]];
    
    self.viewControllers = @[nav1,nav2];
    
    UITabBar *tabbar = self.tabBar;
    UITabBarItem *item0 = [tabbar.items objectAtIndex:0];
    item0.title=@"纵向布局";
    item0.selectedImage = [[UIImage imageNamed:@"vertical_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item0.image = [[UIImage imageNamed:@"vertical"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *item1 = [tabbar.items objectAtIndex:1];
    item1.title = @"横向布局";
    item1.selectedImage = [[UIImage imageNamed:@"horzontal_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    item1.image = [[UIImage imageNamed:@"horzontal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
