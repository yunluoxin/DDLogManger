//
//  AppDelegate+Log.m
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import "AppDelegate+Log.h"

#import "DDLogsViewController.h"

@implementation AppDelegate (Log)

- (void)dd_showLogs
{
#ifndef DEBUG
    return ;
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.window) {
            @throw [NSException exceptionWithName:@"DDLogsFailureAddedException" reason:@"您必须在创建window之后再使用dd_showLogs" userInfo:nil] ;
            return ;
        }
        
        if (!self.window.rootViewController) {
            @throw [NSException exceptionWithName:@"DDLogsFailureAddedException" reason:@"您必须在设置rootViewController之后再使用dd_showLogs" userInfo:nil] ;
            return ;
        }
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [button setTitle:@"查看日志" forState:UIControlStateNormal] ;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
        button.backgroundColor = [UIColor greenColor] ;
        button.frame = CGRectMake(0, 100, 100, 44) ;
        [button addTarget:self action:@selector(dd_click) forControlEvents:UIControlEventTouchUpInside] ;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dd_moveButton:)] ;
        [button addGestureRecognizer:pan] ;
        
        [self.window addSubview:button] ;
        
    }) ;
    
}
- (void)dd_click
{
    if (self.window.rootViewController && self.window.rootViewController.isViewLoaded) {
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[DDLogsViewController new] ] ;
        [self.window.rootViewController presentViewController:nav animated:YES completion:nil] ;
    }
}

- (void)dd_moveButton:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint movement = [pan translationInView:self.window] ;
        [pan setTranslation:CGPointZero inView:self.window] ;
        
        UIView * view = pan.view ;
        CGRect frame = view.frame ;
        frame.origin.x = frame.origin.x + movement.x ;
        frame.origin.y = frame.origin.y + movement.y ;
        view.frame = frame ;
    }
}
@end
