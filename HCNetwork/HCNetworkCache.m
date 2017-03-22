//
//  HCNetworkCache.m
//  缓存机制
//
//  Created by Mac on 16/11/10.
//  Copyright © 2016年 Zhu. All rights reserved.
//

#import "HCNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>

static YYCache *_yyCache;

@implementation HCNetworkCache
+ (void)initialize{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    _yyCache = [YYCache cacheWithPath:path];
    _yyCache.memoryCache.shouldRemoveAllObjectsOnMemoryWarning = YES;
    _yyCache.memoryCache.shouldRemoveAllObjectsWhenEnteringBackground = YES;
}


#pragma mark -------------------- 存储数据 --------------------
+ (void)cacheResponseObject:(id)responseObject
                 requestUrl:(NSString *)requestUrl
                     params:(NSDictionary *)params{
//    assert(responseObject); // 储存数据不能为空!
//    assert(requestUrl);     // 请求地址不能为空！
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@-%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    [_yyCache setObject:responseObject forKey:hash withBlock:^{
        
    }];
}


#pragma mark -------------------- 获取数据 --------------------
+ (id)getCacheResponseObjectWithRequestUrl:(NSString *)requestUrl
                                    params:(NSDictionary *)params{
//    assert(requestUrl);     // 请求地址不能为空！
    
    if (!params) params = @{};
    NSString *originString = [NSString stringWithFormat:@"%@-%@",requestUrl,params];
    NSString *hash = [self md5:originString];
    
    id cacheData = [_yyCache objectForKey:hash];
    return cacheData;
}





#pragma mark -------------------- 散列值 --------------------
+ (NSString *)md5:(NSString *)string {
    if (string == nil || string.length == 0) {
        return nil;
    }
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH],i;
    
    CC_MD5([string UTF8String],(int)[string lengthOfBytesUsingEncoding:NSUTF8StringEncoding],digest);
    
    NSMutableString *ms = [NSMutableString string];
    
    for (i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [ms appendFormat:@"%02x",(int)(digest[i])];
    }
    
    return [ms copy];
}


+ (NSInteger)totalDiskCacheSize{
    return [_yyCache.diskCache totalCost];
}

+ (void)removeAllObjectsWithBlock:(void(^)(void))block{
    [_yyCache removeAllObjectsWithBlock:block];
}


@end
