//
//  HCNetworkCache.h
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYCache/YYCache.h>
/// 对 YYCache 的封装，使用与 HCNetwork 的数据缓存
@interface HCNetworkCache : NSObject

+ (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params;

+ (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params;


+ (NSInteger)totalDiskCacheSize;


+ (void)removeAllObjectsWithBlock:(void(^)(void))block;

@end
