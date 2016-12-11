//
//  DDLogManager.m
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import "DDLogManager.h"

#define LogsSavedDirectory ([[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"logs"])

@interface DDLogManager ()

@property (nonatomic, strong) UIWindow * logWindow ;

@end

@implementation DDLogManager

+ (instancetype)sharedLogManager
{
    static DDLogManager * manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init] ;
    });
    return manager ;
}

- (void)setAllowedLog:(BOOL)allowedLog
{
    _allowedLog = allowedLog ;
    
    [self configure] ;
}

- (void)configure
{
    
#ifndef DEBUG
    //非Debug环境，直接返回
    return ;
#endif
    
    if (self.allowedLog == NO) {
        return ;
    }
    
    //如果已经连接Xcode调试则不输出到文件
    if(isatty(STDOUT_FILENO)) {
        return;
    }
    
    NSString *dir = LogsSavedDirectory ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:dir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil] ;
    }
    
    NSDate *date = [NSDate date] ;
    NSDateFormatter *sdf = [[NSDateFormatter alloc]init] ;
    sdf.locale = [NSLocale localeWithLocaleIdentifier:@"zh_cn"] ;
    sdf.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *formatStr = [sdf stringFromDate:date] ;
    
    NSString *filePath = [dir stringByAppendingFormat:@"/%@.log",formatStr] ;
    NSLog(@"%@",filePath) ;
    freopen([filePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
}

+ (NSArray *)namesOfFilesAtLogsDirectory
{
    NSString *dir = LogsSavedDirectory ;
    NSError *error ;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:&error] ;
    if (error || files == nil) {
        return @[];
    }
    return files ;
}

+ (NSString *)contentsAtPath:(NSString *)filePath
{
    if (!filePath) return nil ;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) return nil ;
    
    NSError * error ;
    NSString * content = [[NSString alloc]initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] ;
    if (!error) {
        return content ;
    }
    return nil ;
}

+ (BOOL)deleteFileAtPath:(NSString *)filePath
{
    if (!filePath) return NO ;
    
    NSError * error ;
    BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error] ;
    if (result && !error) {
        return YES ;
    }
    return NO ;
}

- (NSString *)logsDirectory
{
    return LogsSavedDirectory ;
}

- (UIWindow *)logWindow
{
    if (!_logWindow) {
        _logWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 100, 100, 44) ] ;
        _logWindow.hidden = NO ;
        _logWindow.rootViewController = [LogWindowRootController new] ;
    }
    return _logWindow ;
}

- (void)dd_showLogs
{
#ifndef DEBUG
    return ;
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.logWindow) {
            @throw [NSException exceptionWithName:@"DDLogsFailureAddedException" reason:@"您必须在创建window之后再使用dd_showLogs" userInfo:nil] ;
            return ;
        }
        
        if (!self.logWindow.rootViewController) {
            @throw [NSException exceptionWithName:@"DDLogsFailureAddedException" reason:@"您必须在设置rootViewController之后再使用dd_showLogs" userInfo:nil] ;
            return ;
        }
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [button setTitle:@"查看日志" forState:UIControlStateNormal] ;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
        button.backgroundColor = [UIColor greenColor] ;
        button.frame = self.logWindow.bounds ;
        [button addTarget:self action:@selector(dd_click) forControlEvents:UIControlEventTouchUpInside] ;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dd_moveButton:)] ;
        [button addGestureRecognizer:pan] ;
        [self.logWindow addSubview:button] ;
        
    }) ;
    
}

- (void)dd_click
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow ;
    if (window.rootViewController && window.rootViewController.isViewLoaded) {
        Class clazz = NSClassFromString(@"DDLogsViewController");
        if (clazz) {
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[clazz new] ] ;
            [window.rootViewController presentViewController:nav animated:YES completion:nil] ;
        }
    }
}

- (void)dd_moveButton:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        UIWindow * window = [UIApplication sharedApplication].keyWindow ;
        
        CGPoint movement = [pan translationInView:window] ;
        [pan setTranslation:CGPointZero inView:window] ;
        
        UIView * view = self.logWindow ;
        CGRect frame = view.frame ;
        frame.origin.x = frame.origin.x + movement.x ;
        frame.origin.y = frame.origin.y + movement.y ;
        view.frame = frame ;
    }
}
@end


@implementation LogWindowRootController

- (BOOL)prefersStatusBarHidden
{
    return NO ;
}

@end
