//
//  ViewController.m
//  HCNetworkDemo
//
//  Created by Alicks zhu on 2017/3/22.
//  Copyright © 2017年 HC. All rights reserved.
//

#import "ViewController.h"

// 推荐使用Pods 安装 ---- pod 'HCNetwork'
#import <HCNetwork/HCNetwork.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    /**
     POST 请求自动缓存  useCache  是否先加载缓存，如果是，则先加载缓存，执行 success Block，网络加载成功之后，再一次加载 success block。 无论选择是否，断网情况下都会加载缓存。
     @param useCache     是否先加载缓存，如果是，则先加载缓存，执行 success Block，网络加载成功之后，再一次加载 success block。 无论选择是否，断网情况下都会加载缓存。
     */
    [HCNetwork POST:@"https://www.jpush.cn" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"---------------------------------%@",responseObject);
        // 返回数据类型务必是json格式！
        // 否则会报错：Domain=NSCocoaErrorDomain Code=3840 "JSON text did not start with array or object and option to allow fragments not set.
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------------------------------%@",error);
        
    } showHUD:NO useCache:YES];
    
    
    
    
    /**
     网页GET请求 (没网络会加载缓存)，用于请求网页数据，responseObject 返回的一般是html语言。
     一般会配合webview加载html语言显示网页。
     注意：该请求方法比较少用。
     */
    [HCNetwork WEBGET:@"https://www.jpush.cn"  parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"---------------------------------%@",responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------------------------------%@",error);
        
    } showHUD:NO];

    
}




@end
