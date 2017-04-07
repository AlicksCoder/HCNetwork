//
//  HCNetwork.m
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import "HCNetwork.h"
#import "HCNetworkCache.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <CommonCrypto/CommonHMAC.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import <arpa/inet.h>

static AFHTTPSessionManager *_manager;
static AFHTTPSessionManager *_webManager;
static AFNetworkReachabilityStatus _status = 0;
static UIView *_statusBar;

@implementation HCNetwork
#pragma mark -------------------------------- 初始化 --------------------------------
+ (void)initialize{
    [HCNetwork checkNetworkStatus];
    _statusBar = [HCNetwork initialStatusBar];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    _manager = [HCNetwork setHttpSessionManagerType:YES];
    _webManager = [HCNetwork setHttpSessionManagerType:NO];
}

+ (AFHTTPSessionManager *)setHttpSessionManagerType:(BOOL)isJson{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    if (isJson) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }else{
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
    manager.requestSerializer.timeoutInterval = HCRequestTimeout;
    return manager;
}



#pragma mark -------------------------------- 网络请求 --------------------------------
+(NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure showHUD:(BOOL)showHUD{
    __block NSURLSessionDataTask *session = nil;
    
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    
    if(showHUD)  NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    session = [_manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success ? success(task,responseObject) : 0;
        
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) : 0;
    }];
    
    [session resume];
    return session;
}

+ (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure showHUD:(BOOL)showHUD useCache:(BOOL)useCache{
    
    __block NSURLSessionDataTask *session = nil;
    if(showHUD) NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    if (useCache) {
        id responseObject = [HCNetworkCache getCacheResponseObjectWithRequestUrl:URLString params:parameters];
        
        if (responseObject) {
            success ? success(session,responseObject) : 0;
        }
    }
    
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    
    session = [_manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(session,responseObject) : 0;
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(session,error) : 0;
    }];
    
    [session resume];
    return session;
}


+ (NSURLSessionDataTask *)WEBGET:(NSString *)URLString
                      parameters:(id)parameters
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                         showHUD:(BOOL)showHUD{
    __block NSURLSessionDataTask *session = nil;
    if ([HCNetwork doSomethingIfTheNetworkUnable:URLString parameters:parameters success:success failure:failure] && _status == AFNetworkReachabilityStatusNotReachable) return session;
    if(showHUD)  NSLog(@"显示 hud 改功能暂无，后续版本添加 加载中...");
    
    session = [_webManager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject class] isSubclassOfClass:[NSData class]]) {
            responseObject = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        }
        
        success ? success(task,responseObject) : 0;
        [HCNetworkCache cacheResponseObject:responseObject requestUrl:URLString params:parameters];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) : 0;
    }];
    
    [session resume];
    return session;
}


+(NSURLSessionDataTask *)GETNOCache:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
     __block NSURLSessionDataTask *session = nil;
    session = [_manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(task,responseObject) : 0;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(task,error) : 0;
    }];
    
    [session resume];
    return session;
}


+(NSURLSessionDataTask *)POSTNOCache:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    __block NSURLSessionDataTask *session = nil;
    session = [_manager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success ? success(session,responseObject) : 0;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure ? failure(session,error) : 0;
    }];

    [session resume];
    return session;
}

#pragma mark -------------------------------- 检查网络 --------------------------------
+(void)checkNetworkStatus{
    if ([HCNetwork connectedToNetwork]) _status = 1;
    AFNetworkReachabilityManager *mgr = [AFNetworkReachabilityManager sharedManager];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        _status = status;
        if (status < 1) {
            [HCNetwork showStatusBarWhenNotReachable:YES];
        }else{
            [HCNetwork showStatusBarWhenNotReachable:NO];
        }
    }];
    [mgr startMonitoring];
    
}

+(AFNetworkReachabilityStatus) currentNetworkStatus {
    return _status;
}

+(BOOL)doSomethingIfTheNetworkUnable:(NSString *)URLString parameters:(id)parameters success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure{
    if (_status == -1 || _status == 0) {
        NSError *er;
        if (_status == -1) {
            er = [NSError errorWithDomain:@"com.HCNetwork.unkonwStatus" code:600 userInfo:@{NSLocalizedDescriptionKey:@"无法判断当前网络"}];
        }else{
            er = [NSError errorWithDomain:@"com.HCNetwork.unreacheStatus" code:601 userInfo:@{NSLocalizedDescriptionKey:@"当前无网络连接"}];
        }
        failure ? failure(nil,er) : 0;
        id responseObject = [HCNetworkCache getCacheResponseObjectWithRequestUrl:URLString params:parameters];
        if (responseObject) {
            success ? success(nil,responseObject) : 0;
        }
        return YES;
    }
    return NO;
}

/// 神奇方法
+ (BOOL)connectedToNetwork {
    // 创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // SCNetworkReachabilityCreateWithAddress：根据传入的IP地址测试连接状态，当为0.0.0.0时则可以查询本机的网络连接状态。
    // 使用SCNetworkReachabilityCreateWithAddress：可以根据传入的网址地址测试连接状态
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags) return NO;
    
    // kSCNetworkReachabilityFlagsReachable：能够连接网络
    // kSCNetworkReachabilityFlagsConnectionRequired：能够连接网络，但是首先得建立连接过程
    // kSCNetworkReachabilityFlagsIsWWAN：判断是否通过蜂窝网覆盖的连接
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
    
}


#pragma mark -------------------------------- 状态提示栏  --------------------------------
+ (void)showStatusBarWhenNotReachable:(BOOL)isShow;{
    if (isShow && _statusBar.tag == 0) {
        _statusBar.tag = 1;
        [[UIApplication sharedApplication].keyWindow addSubview:_statusBar];
    }else {
        _statusBar.tag = 0;
        [_statusBar removeFromSuperview];
    }
}

+ (UIView *)initialStatusBar{
    UIView *bar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 25)];
    bar.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] initWithFrame:bar.bounds];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"网络中断";
    label.textColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:14];
    bar.tag = 0;
    [bar addSubview:label];
    
    return bar;
}


#pragma mark -------------------------------- 清除磁盘网络缓存数据 --------------------------------
+ (void)removeAllObjectsWithBlock:(void(^)(void))block{
    [HCNetworkCache removeAllObjectsWithBlock:block];
}

+ (NSInteger)totalDiskCacheSize{
    return [HCNetworkCache totalDiskCacheSize];
}
@end
