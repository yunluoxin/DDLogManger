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
{
    NSString * _latestLogPath ;
}

@property (nonatomic, strong) UIWindow * logWindow ;

@property (nonatomic, weak  ) UIWindow * originKeyWindow ;
/**
    '查看日志'按钮
 */
@property (nonatomic, strong) UIButton * showButton ;
/**
    模拟控制台输出的textView
*/
@property (nonatomic, strong) UITextView * logTextView ;

@property (nonatomic, strong) NSTimer * timer ;
@end

@implementation DDLogManager

+ (instancetype)sharedLogManager
{
#ifndef DEBUG
    //非Debug环境，直接返回
    return nil ;
#endif
    
    static DDLogManager * manager ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init] ;
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(configure) name:UIApplicationDidFinishLaunchingNotification object:nil] ;
        [[NSNotificationCenter defaultCenter] addObserver:manager selector:@selector(changeKeyWindow:) name:UIWindowDidBecomeKeyNotification object:nil] ;
    });
    return manager ;
}

- (void)configure
{
    //如果已经连接Xcode调试则不输出到文件
//    if(isatty(STDOUT_FILENO)) {
//        return;
//    }
    
    if (!self.allowedLog) {
        return ;
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
    _latestLogPath = filePath ;
    NSLog(@"%@",filePath) ;
    
    freopen([filePath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stdout);
    
    //have to write this, because even you don't use NSLog or you have redifine NSLog, many logs in system library use stderr to output.
    freopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "a++", stderr);
    
    if (!self.needConsoleOutput && !self.showLogsList) {
        return ;
    }
    
    UIWindow * keyWindow = [UIApplication sharedApplication].keyWindow ;
    
    self.originKeyWindow = keyWindow ;  //Store the origin key window ! In case that it changed by others and give key property to logWindow.
    
    if (self.needConsoleOutput) {
        
        [self.logWindow addSubview:self.logTextView] ;
        
        [self beginMonitorFileChange] ;
    }
    
    if (self.showLogsList) {
        [self.logWindow addSubview:self.showButton] ;
    }
}

- (void)changeKeyWindow:(NSNotification * )note
{
    if (!self.originKeyWindow)
    {
        return ;
    }else
    {
        //2016.12.12 修复bug ，由于高德地图等原因， 关闭后，logWindow成为了主window，需要进行重置，否则出错。
        if ([UIApplication sharedApplication].keyWindow == self.logWindow) {
            [self.originKeyWindow makeKeyWindow] ;
        }
    }
}

#pragma mark - Actions 

//开始检测文件变化
- (void)beginMonitorFileChange
{
    [self timer] ;
}

- (void)scanFileChange
{
    if (!_latestLogPath) {
        return ;
    }
    NSError * error ;
    NSString * text = [[NSString alloc] initWithContentsOfFile:_latestLogPath encoding:NSUTF8StringEncoding error:&error] ;
    self.logTextView.text = text ;
    if (error) {
        [_timer invalidate] ;
        _timer = nil ;
        
        _latestLogPath = nil ;
    }
}

- (void)dd_click
{
    if (self.originKeyWindow && self.originKeyWindow.rootViewController && self.originKeyWindow.rootViewController.isViewLoaded) {
        Class clazz = NSClassFromString(@"DDLogsViewController");
        if (clazz) {
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:[clazz new] ] ;
            [self.originKeyWindow.rootViewController presentViewController:nav animated:YES completion:nil] ;
        }
    }
}

- (void)dd_moveWindow:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateChanged) {
        CGPoint movement = [pan translationInView:self.originKeyWindow] ;
        [pan setTranslation:CGPointZero inView:self.originKeyWindow] ;
        
        UIView * view = self.logWindow ;
        CGRect frame = view.frame ;
        frame.origin.x = frame.origin.x + movement.x ;
        frame.origin.y = frame.origin.y + movement.y ;
        view.frame = frame ;
    }
}

#pragma mark - Utils methos

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


#pragma mark - setter and getter

- (UIWindow *)logWindow
{
    if (!_logWindow) {
        if (self.needConsoleOutput) {
            CGFloat h = 100 ;
            CGFloat y = [UIScreen mainScreen].bounds.size.height - h ;
            CGFloat w = [UIScreen mainScreen].bounds.size.width ;
            CGFloat x= 0 ;
            _logWindow = [[UIWindow alloc] initWithFrame:CGRectMake(x, y, w, h ) ] ;
        }else{
            _logWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 100, 80, 30 ) ] ;
        }
        _logWindow.hidden = NO ;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dd_moveWindow:)] ;
        [_logWindow addGestureRecognizer:pan] ;
        _logWindow.rootViewController = [LogWindowRootController new] ;
    }
    return _logWindow ;
}

- (UIButton *)showButton
{
    if (!_showButton) {
        _showButton = [UIButton buttonWithType:UIButtonTypeCustom] ;
        [_showButton setTitle:@"查看日志" forState:UIControlStateNormal] ;
        [_showButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal] ;
        _showButton.backgroundColor = [UIColor greenColor] ;
        [_showButton addTarget:self action:@selector(dd_click) forControlEvents:UIControlEventTouchUpInside] ;
        if (self.needConsoleOutput) {
            CGFloat h = 30 ;
            CGFloat y = 0 ;
            CGFloat w = 100 ;
            CGFloat x = self.logWindow.bounds.size.width - w ;
            _showButton.frame = CGRectMake(x, y , w , h ) ;
        }else{
            _showButton.frame = self.logWindow.bounds ;
        }
    }
    return _showButton ;
}

- (UITextView *)logTextView
{
    if (!_logTextView) {
        _logTextView = [[UITextView alloc] initWithFrame:self.logWindow.bounds] ;
        _logTextView.textColor = [UIColor greenColor] ;
        _logTextView.backgroundColor = [UIColor blackColor] ;
        _logTextView.font = [UIFont systemFontOfSize:11] ;
        _logTextView.editable = NO ;
    }
    return _logTextView ;
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(scanFileChange) userInfo:nil repeats:YES] ;
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes] ;
    }
    return _timer ;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}
@end


@implementation LogWindowRootController

- (BOOL)prefersStatusBarHidden
{
    return NO ;
}

@end
