//
//  HCNetwork.h
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


static NSTimeInterval HCRequestTimeout = 30.0f;    ///请求超时时间
/// 对 AFNetworking 的封装 集成缓存机制
@interface HCNetwork : NSObject

/**
 GET请求自动缓存 (没网络会加载缓存)
 */
+ (NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(id)parameters
                               success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                               failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                                showHUD:(BOOL)showHUD;

/**
 POST 请求自动缓存  useCache  是否先加载缓存，如果是，则先加载缓存，执行 success Block，网络加载成功之后，再一次加载 success block。 无论选择是否，断网情况下都会加载缓存。
 @param useCache     是否先加载缓存，如果是，则先加载缓存，执行 success Block，网络加载成功之后，再一次加载 success block。 无论选择是否，断网情况下都会加载缓存。
 */
+ (NSURLSessionDataTask *)POST:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                        showHUD:(BOOL)showHUD
                        useCache:(BOOL)useCache;


/**
 网页GET请求 (没网络会加载缓存)，用于请求网页数据，responseObject 返回的一般是html语言。
 一般会配合webview加载html语言显示网页。
 */
+ (NSURLSessionDataTask *)WEBGET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                      showHUD:(BOOL)showHUD;



/**
 GET请求不处理缓存。不进行缓存。
 */
+ (NSURLSessionDataTask *)GETNOCache:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 POST 请求不处理缓存。不进行缓存。
 */
+ (NSURLSessionDataTask *)POSTNOCache:(NSString *)URLString
                    parameters:(id)parameters
                       success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                       failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


/** ----------------------------------------  提示栏  ---------------------------------------- **/
/**
 当断网时显示断网提示栏。

 @param isShow 是否显示
 */
+ (void)showStatusBarWhenNotReachable:(BOOL)isShow;





/** ----------------------------------------  缓存磁盘容量  ---------------------------------------- **/
/**
 获取当前磁盘网络缓存数据所占的空间
 @return  单位 bytes
 */
+ (NSInteger)totalDiskCacheSize;

/**
 清除磁盘上所有网络缓存数据
 @param block 完成回调
 */
+ (void)removeAllObjectsWithBlock:(void(^)(void))block;

@end

/***  更新日志
    0.01 - 添加无缓存请求
 
 
 
 ***/
