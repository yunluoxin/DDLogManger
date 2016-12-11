//
//  DDLogsViewController.m
//  DDLogManger
//
//  Created by ZhangXiaodong on 16/12/9.
//  Copyright © 2016年 DDLogManager. All rights reserved.
//

#import "DDLogsViewController.h"
#import "DDLogManager.h"
#import "DDLogsDetailController.h"
@interface DDLogsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView ;

/**
 数据源 -- 从目录中读取的logs
 */
@property (nonatomic, strong) NSMutableArray * logs ;

/**
 当前选中的logs
 */
@property (nonatomic, strong) NSMutableArray * selectedLogs ;
@end

@implementation DDLogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"日志列表" ;
    
    self.navigationController.navigationBar.barTintColor = [UIColor purpleColor] ;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] ;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)] ;
    
    [self.view addSubview:self.tableView] ;
    
    [self setupDeleteButton] ;
}

- (void)setupDeleteButton
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom] ;
    [button setTitle:@"删除选中的" forState:UIControlStateNormal] ;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
    button.backgroundColor = [UIColor redColor] ;
    button.frame = CGRectMake(0, self.view.bounds.size.height - 44 , self.view.bounds.size.width, 44) ;
    [button addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside] ;
    [self.view addSubview:button] ;
}

#pragma mark - UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logs.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell" ;
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier ] ;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] ;
        
    }
    
    cell.textLabel.text = self.logs[indexPath.row] ;
    
    return cell ;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == (UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert)) {
        NSLog(@"%s",__func__) ;
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing) {
        [self.selectedLogs addObject:self.logs[indexPath.row]] ;
        return ;
    }
    
    __weak typeof(self) wself = self ;
    DDLogsDetailController * vc = [DDLogsDetailController new] ;
    NSString *fileName = self.logs[indexPath.row] ;
    NSString *filePath = [[DDLogManager sharedLogManager].logsDirectory stringByAppendingPathComponent:fileName] ;
    vc.filePath = filePath ;
    vc.title = fileName ;
    vc.whenPopVC = ^(){
        [wself.logs removeObject:fileName] ;
        [wself.tableView reloadData] ;
    } ;
    [self.navigationController pushViewController:vc animated:YES] ;
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedLogs removeObject:self.logs[indexPath.row]] ;
}


#pragma mark - Actions

- (void)edit
{
    self.tableView.editing = !self.tableView.isEditing ;
    
    if (self.tableView.isEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] ;
        
        //完成--就清理刚刚选中的logs
        self.selectedLogs = nil ;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] ;
    }
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (void)delete
{
    if (self.selectedLogs.count == 0) {
        return ;
    }
    
    NSArray * temp = self.selectedLogs.copy ;
    for (NSString * fileName in temp) {
        NSString *filePath = [[DDLogManager sharedLogManager].logsDirectory stringByAppendingPathComponent:fileName] ;
        BOOL result = [DDLogManager deleteFileAtPath:filePath] ;
        if (result) {
            [self.logs removeObject:fileName] ;
            [self.selectedLogs removeObject:fileName] ;
        }
    }
    [self.tableView reloadData] ;
}

#pragma mark - lazy load

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped] ;
        _tableView.delegate = self ;
        _tableView.dataSource = self ;
        _tableView.rowHeight = 44.0f ;
        
    }
    return _tableView ;
}

- (NSMutableArray *)logs
{
    if (!_logs) {
        _logs = [[DDLogManager namesOfFilesAtLogsDirectory] mutableCopy];
    }
    return _logs ;
}

- (NSMutableArray *)selectedLogs
{
    if (!_selectedLogs) {
        _selectedLogs = @[].mutableCopy ;
    }
    return _selectedLogs ;
}
@end
