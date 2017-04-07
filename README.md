# HCNetwork
AFNetworking+YYCache.
> If I have been able to see further, it was only because I stood on the shoulders of giants. 
-------


### It's very easy!!
Just use it.

### Installation with CocoaPods

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'HCNetwork', '~> 1.0.1'
end
```

### 简单示例

```
    /**
     POST 请求自动缓存  
     @param useCache     是否先加载缓存，如果是，则先加载缓存，执行 success Block，
     网络加载成功之后，再一次加载 success block。 无论选择是否，断网情况下都会加载缓存。
     */
    [HCNetwork POST:@"https://www.jpush.cn" parameters:nil 
    success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"---------------------------------%@",responseObject);
        // 返回数据类型务必是json格式！
        // 否则会报错：Domain=NSCocoaErrorDomain Code=3840
        // "JSON text did not start with array or object and option to allow fragments not set.
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"----------------------------------%@",error);
        
    } showHUD:NO useCache:YES];
```


### License

HCNetwork is released under the MIT license. See LICENSE for details.

