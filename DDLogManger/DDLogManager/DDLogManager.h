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

@property (nonatomic, assign)BOOL allowedLog ;

@property (nonatomic, readonly)NSString * logsDirectory ;
- (void)dd_showLogs ;
+ (instancetype)sharedLogManager ;

+ (NSArray *)namesOfFilesAtLogsDirectory ;

+ (NSString *)contentsAtPath:(NSString *)filePath ;

+ (BOOL)deleteFileAtPath:(NSString *)filePath ;
@end
