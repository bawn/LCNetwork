# LCNetwork

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/LCNetwork.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)


基于 `AFNetworking` 的封装，参考了[YTKNetwork](https://github.com/yuantiku/YTKNetwork)的实现方式，
采用离散型的API调用方式。

##功能
1. 支持`block`和`delegate`的回调方式
2. 支持设置主、副两个服务器地址
3. 支持`response`缓存，基于`TMCache`
4. 支持统一的`argument`加工
5. 支持统一的`response`加工
6. 支持检查返回 JSON 内容的合法性
7. 支持多个请求同时发送，并统一设置它们的回调
8. 支持以类似于插件的形式显示HUD

__最终在 `ViewController` 中调用一个接口请求的例子如下__

```
Api2 *api2 = [[Api2 alloc] init];
api2.requestArgument = @{
                         @"lat" : @"34.345",
                         @"lng" : @"113.678"
                         };
[api2 startWithCompletionBlockWithSuccess:^(Api2 *api2) {
    self.weather2.text = api2.responseJSONObject[@"Weather"];
} failure:NULL];

```


##集成

Cocoapods:
```
pod 'LCNetwork'
```

##使用
###统一配置

__`LCNetworkConfig` 类提供的两个功能：__

1. 设置服务器地址
2. 设置是否打印请求的log信息

```
LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
config.mainBaseUrl = @"http://api.zdoz.net/";// 设置主服务器地址
config.viceBaseUrl = @"https://api.zdoz.net/";// 设置副服务器地址
config.logEnabled = YES;// 是否打印请求的log信息
```

###创建接口调用类
每个请求都需要一个对应的类去执行，这样的好处是接口所需要的信息都集成到了这个API类的内部，不在暴露在Controller层。

创建一个API类需要继承`LCBaseRequest`类，并且遵守`LCAPIRequest`协议，下面是最基本的API类的创建。

__Api1.h__

```
#import <LCNetwork/LCBaseRequest.h>

@interface Api1 : LCBaseRequest<LCAPIRequest>

@end
```
__Api1.m__
```
#import "Api1.h"

@implementation Api1

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

@end
```
`- (NSString *)apiMethodName` 和 `- (LCRequestMethod)requestMethod` 是 @required 方法，所以必须实现，这在一定程度上降低了因漏写方法而crash的概率。

另外 @optional 方法提供了如下的功能

```
// 是否使用副Url
- (BOOL)useViceUrl;

// 是否缓存数据 response 数据
- (BOOL)cacheResponse;

// 超时时间
- (NSTimeInterval)requestTimeoutInterval;

// 用于Body数据的block
- (AFConstructingBlock)constructingBodyBlock;

// json数据类型验证
- (NSDictionary *)jsonValidator;

// response处理
- (id)responseProcess;

```

###参数设置

请求的参数可以在外部设置，例如：
```
Api2 *api2 = [[Api2 alloc] init];
api2.requestArgument = @{
                          @"lat" : @"34.345",
                          @"lng" : @"113.678"
                        };
```
如果不想把参数的 key 值暴露在外部，也可以在 API 类中自定义初始化方法，例如:

__Api2.h__
```
@interface Api2 : LCBaseRequest<LCAPIRequest>

- (instancetype)initWith:(NSString *)lat lng:(NSString *)lng;

@end
```

__Api2.m__

```
#import "Api2.h"

@implementation Api2

- (instancetype)initWith:(NSString *)lat lng:(NSString *)lng{
    self = [super init];
    if (self) {
                self.requestArgument = @{
                                 @"lat" : lat,
                                 @"lng" : lng
                                 };
    }
    return self;
}
```
直接在初始化方法中使用 `self.requestArgument = @{@"lat" : lat, lng" : lng}` 其实不妥，原因请参考 [唐巧](http://blog.devtang.com/blog/2011/08/10/do-not-use-accessor-in-init-and-dealloc-method/) 和 [jymn_chen](http://blog.csdn.net/jymn_chen/article/details/25000575)，如果想完全规避这样的问题，请参考demo中的实现


###统一处理`argument` 和 `response`

这里需要用到另外一个协议 ` <LCProcessProtocol>`，比如我们的每个请求需要添加一个关于版本的参数：

__LCProcessFilter.h__
```
#import "LCNetworkConfig.h"

@interface LCProcessFilter : NSObject <LCProcessProtocol>

@end
```
__LCProcessFilter.m__

```
#import "LCBaseRequest.h"

@implementation LCProcessFilter

- (NSDictionary *) processArgumentWithRequest:(NSDictionary *)argument{
     NSMutableDictionary *newParameters = [[NSMutableDictionary alloc] initWithDictionary:argument];
    [newParameters setObject:@"1.0.0" forKey:@"version"];
    return newParameters;
}
```
最后，赋值给 `LCNetworkConfig` 的 `processRule`
```
LCProcessFilter *filter = [[LCProcessFilter alloc] init];
config.processRule = filter;
```

 
##更多信息
参考自带的 Demo 或是我的[博客](http://bawn.github.io/ios/afnetworking/2015/08/10/LCNetwork.html)

##Requirements
* iOS 6 or higher
* ARC


##License
[MIT](http://mit-license.org/)
