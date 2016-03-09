//
//  CYXOneViewController.m
//  
//
//  Created by Macx on 15/9/4.
//  Copyright (c) 2015年 CYX. All rights reserved.
//

#import "CYXOneViewController.h"
#import "CYXCell.h"
#import "CYXMenu.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import <MJRefresh.h>

@interface CYXOneViewController ()

/** 存放数据模型的数组 */
@property (strong, nonatomic) NSMutableArray<CYXMenu *> * menus;
/** 请求管理者 */
@property (nonatomic,weak) AFHTTPSessionManager * manager;
/** 用于加载下一页的参数(页码) */
@property (nonatomic,assign) NSInteger pn;
@end

@implementation CYXOneViewController

#pragma mark - 全局常量
static NSString * const CYXRequestURL = @"http://apis.haoservice.com/lifeservice/cook/query?";
static NSString * const CYXCellID = @"cell";

#pragma mark - 懒加载

/** manager 懒加载*/
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}


#pragma mark - life cycle 生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTable];
        
}

#pragma mark - private methods 私有方法

- (void)setupTable{
    self.tableView.rowHeight = 90;
    
    // 注册重用Cell
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([CYXCell class]) bundle:nil] forCellReuseIdentifier:CYXCellID];
    
    self.view.backgroundColor = [UIColor whiteColor];

    // 头部刷新控件
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    [self.tableView.header beginRefreshing];
    
    // 尾部刷新控件
    self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
}


#pragma mark - 请求数据方法
/**
 *  发送请求并获取数据方法
 */
- (void)loadData{
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    self.pn = 1;
    // 请求参数（根据接口文档编写）
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"menu"] = @"西红柿";
    params[@"pn"] = @(self.pn);
    params[@"rn"] = @"10";
    params[@"key"] = @"2ba215a3f83b4b898d0f6fdca4e16c7c";
    
    // 在AFN的block内使用，防止造成循环引用
    __weak typeof(self) weakSelf = self;
    
    [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    [self.manager GET:CYXRequestURL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"请求成功");
        
        // 利用MJExtension框架进行字典转模型
        weakSelf.menus = [CYXMenu objectArrayWithKeyValuesArray:responseObject[@"result"]];
        weakSelf.pn ++;
        // 刷新数据（若不刷新数据会显示不出）
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"请求失败 原因：%@",error);
        [weakSelf.tableView.header endRefreshing];
    }];
    
}
/**
 *  加载更多数据
 */
- (void)loadMoreData{
    
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 请求参数（根据接口文档编写）
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"menu"] = @"西红柿";
    params[@"pn"] = @(self.pn);
    params[@"rn"] = @"10";
    params[@"key"] = @"2ba215a3f83b4b898d0f6fdca4e16c7c";
    
    // 在AFN的block内使用，防止造成循环引用
    __weak typeof(self) weakSelf = self;
    
    [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    
    [self.manager GET:CYXRequestURL parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"请求成功");
        
        
        // 利用MJExtension框架进行字典转模型
        NSArray *array = [CYXMenu objectArrayWithKeyValuesArray:responseObject[@"result"]];
        [weakSelf.menus addObjectsFromArray:array];
        
        weakSelf.pn ++;
        
        // 刷新数据（若不刷新数据会显示不出）
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.footer endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"请求失败 原因：%@",error);
        [weakSelf.tableView.footer endRefreshing];
    }];
    

    
}

#pragma mark - UITableviewDatasource 数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CYXCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.menu = self.menus[indexPath.row];
    
    return cell;
}

#pragma mark - UITableviewDelegate 代理方法

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 点击了第indexPath.row行Cell所做的操作
}

@end
