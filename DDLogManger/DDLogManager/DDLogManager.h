//
//  DDLogManager.h
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DDLogManager : NSObject
/**
    是否允许打印到文件（总开关，如果不允许, needConsoleOutput设置也失效）
 */
@property (nonatomic, assign) BOOL allowedLog ;

/**
    是否需要 实时控制台输出
 */
@property (nonatomic, assign) BOOL needConsoleOutput ;

/**
    是否需要 显示日志列表
 */
@property (nonatomic, assign) BOOL showLogsList ;

/** 获取一个单例对象 */
+ (instancetype)sharedLogManager ;


/*===================工具类方法===================*/

/**
 获取当前设置的打印文件所在的目录
 */
@property (nonatomic, readonly)NSString * logsDirectory ;

+ (NSArray *)namesOfFilesAtLogsDirectory ;

+ (NSString *)contentsAtPath:(NSString *)filePath ;

+ (BOOL)deleteFileAtPath:(NSString *)filePath ;

@end

@interface LogWindowRootController : UIViewController

@end
