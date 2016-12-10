//
//  DDLogsDetailController.m
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import "DDLogsDetailController.h"
#import "DDLogManager.h"
@interface DDLogsDetailController ()
@property (nonatomic, strong) UITextView * textView ;
@end

@implementation DDLogsDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor] ;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(delete)] ;
    
    [self.view addSubview:self.textView] ;
    
    self.textView.text = [DDLogManager contentsAtPath:self.filePath] ;
}

- (void)delete
{
    BOOL result = [DDLogManager deleteFileAtPath:self.filePath] ;
    if (result) {
        [self.navigationController popViewControllerAnimated:YES] ;
        if (self.whenPopVC) {
            self.whenPopVC() ;
        }
    }
}

#pragma mark - lazy load
- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:self.view.bounds] ;
//        _textView.delegate = self ;
        _textView.backgroundColor = [UIColor blackColor] ;
        _textView.textColor = [UIColor whiteColor] ;
        _textView.font = [UIFont systemFontOfSize:13] ;
    }
    return _textView ;
}
@end
