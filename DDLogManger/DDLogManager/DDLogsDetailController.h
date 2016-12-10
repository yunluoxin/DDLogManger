//
//  DDLogsDetailController.h
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDLogsDetailController : UIViewController

@property (nonatomic, copy) NSString * filePath ;

@property (nonatomic, copy) void (^whenPopVC)() ;
@end
