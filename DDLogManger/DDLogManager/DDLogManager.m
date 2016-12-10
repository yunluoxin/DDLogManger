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
@end
