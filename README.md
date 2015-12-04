# LCNetwork

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/LCNetwork.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)


基于 `AFNetworking` 的封装，参考了[YTKNetwork](https://github.com/yuantiku/YTKNetwork)的实现方式，
接口类采用 @protocol 约束，让调用者可以更清晰的知道那些方法需要被实现，那些功能可以被添加。

若遇到 Demo 闪退问题，请删除 APP 重新运行，另外感谢[zdoz](http://api.zdoz.net/)提供免费的测试接口。

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
- (id)responseProcess:(id)responseObject;

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

或者是处理类似于下面的 json 数据，服务端返回的数据结构都会带`result` 和 `ok` 的 key
```
{
  "result": {
      "_id": "564a931dbbb03c7002a2c0f3",
      "name": "clover",
      "count": 0
    },

  "ok": true,
  "message" : "成功"
}
```
那么可以这样处理

```
- (id) processResponseWithRequest:(id)response{
    if ([response[@"ok"] boolValue]) {
        return response[@"result"];
    }
    else{
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: response[@"message"]};
        return [NSError errorWithDomain:ErrorDomain code:0 userInfo:userInfo];
    }
}

```
也就是说当使用 `api1.responseJSONObject` 获取数据时，返回的直接是 `result` 对应的值，或者是错误信息。

最后，赋值给 `LCNetworkConfig` 的 `processRule`
```
LCProcessFilter *filter = [[LCProcessFilter alloc] init];
config.processRule = filter;
```

### multipart/form-data 

通常我们会用到上传图片或者其他文件就需要用到 `multipart/form-data`，同样的只需要实现`- (AFConstructingBlock)constructingBodyBlock;`协议方法即可，比如
```
- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"currentPageDot"], 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}
```


### response 再加工

当类似于
```
{
  "result": {
      "_id": "564a931dbbb03c7002a2c0f3",
      "name": "clover",
      "count": 10
    },

  "ok": true,
  "message" : "成功"
}
```
这样的数据，如果已经对 response 做了统一的加工，比如成功后统一返回的数据是 result 中的数据，那么返回的也是一个 `NSDictionary`，可能无法满足需求，这时候再把数据交给 `LCBaseRequest` 子类处理再合适不过了。比如需要直接获取`count`值，那么只需要实现 `- (id)responseProcess:(id)responseObject;` 协议方法，具体如下

```
- (id)responseProcess:(id)responseObject{
    return responseObject[@"count"];
}
```
__注意，不应该调用`self.responseJSONObject`作为处理数据，请使用`responseObject`来处理__，当实现这个协议方法后，使用 `api1.responseJSONObject` 获取数据时，返回将是 `count` 的值。这里其实有问题，count 返回的值是 10，那么这个 10 是`NSNumber` 还是 `NSString`（不带双引号的数字，不一定就是NSNumber），这时候就会用到 json 格式校验了。

### json 数据校验

还是上面的 json 数据例子，比如需要校验 count 返回的数据类型，那么就需要实现 `- (id)jsonValidator;` 协议方法，具体如下

```
- (id)jsonValidator{
    return @{@"count" : [NSNumber class]};
}
```
__注意，json 数据校验，针对的是最终返回的数据__，也就是说如果只做了统一的参数加工，使用上面的方法才是正确的，因为最终的返回数据是
```
 "_id": "564a931dbbb03c7002a2c0f3",
  "name": "clover",
  "count": 10
```
所以如果做了 response 再加工，那么最终返回的数据是 "count": 10，所以协议方法需要改成
```
- (id)jsonValidator{
    return [NSNumber class];
}
```
### 关于HUD

如何显示 "正在加载"的 HUD，请参考Demo中的 `LCRequestAccessory` 类



##更多信息
参考自带的 Demo 或是我的[博客](http://bawn.github.io/ios/afnetworking/2015/08/10/LCNetwork.html)

##Requirements
* iOS 6 or higher
* ARC


##License
[MIT](http://mit-license.org/)
