//
//  DDLogManager.h
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDLogManager : NSObject

@property (nonatomic, assign)BOOL allowedLog ;

@property (nonatomic, readonly)NSString * logsDirectory ;

+ (instancetype)sharedLogManager ;

+ (NSArray *)namesOfFilesAtLogsDirectory ;

+ (NSString *)contentsAtPath:(NSString *)filePath ;

+ (BOOL)deleteFileAtPath:(NSString *)filePath ;
@end
