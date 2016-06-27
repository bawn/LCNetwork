# LCNetwork

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/LCNetwork.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)
[![Support](https://img.shields.io/badge/support-iOS7+-blue.svg?style=flat)](https://www.apple.com/nl/ios/)


基于 `AFNetworking` 的封装，参考了[YTKNetwork](https://github.com/yuantiku/YTKNetwork)的实现方式，
接口类采用 @protocol 约束，接口类的创建和使用更清晰。已适配 AFNetworking 3.x

若遇到 Demo 闪退问题，请删除 APP 重新运行，另外感谢[zdoz](http://api.zdoz.net/)提供免费的测试接口。

##功能

1. 支持`block`和`delegate`的回调方式
2. 支持设置主、副两个服务器地址
3. 支持`response`缓存，基于[TMCache](https://github.com/tumblr/TMCache)
4. 支持统一的`argument`加工
5. 支持统一的`response`加工
6. 支持多个请求同时发送，并统一设置它们的回调
7. 支持方便地设置有相互依赖的网络请求的发送
8. 支持以类似于插件的形式显示HUD
9. 支持获取请求的实时进度

__最终在 `ViewController` 中调用一个接口请求的例子如下__

```
Api2 *api2 = [[Api2 alloc] init];
api2.requestArgument = @{
                         @"lat" : @"34.345",
                         @"lng" : @"113.678"
                         };
[api2 startWithCompletionBlockWithSuccess:^(__kindof LCBaseRequest *request) {
    self.weather2.text = api2.responseJSONObject[@"Weather"];
} failure:NULL];

```


##集成

CocoaPods:
```
pod 'LCNetwork'
```

##使用
###统一配置


```
LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
config.mainBaseUrl = @"http://api.zdoz.net/";// 设置主服务器地址
config.viceBaseUrl = @"https://api.zdoz.net/";// 设置副服务器地址
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

当然，如果你某个接口的 response 你不想做统一的处理，可以在请求子类中实现
```
- (BOOL)ignoreUnifiedResponseProcess{
    return YES;
}
```
这样返回的 responseJSONObject 就是原始数据

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
对于多图上传可能还会需要知道进度情况，LCNetwork 在 1.1.0 版本之后提供了监听进度的方法，只需要调用
```
 (void)startWithBlockProgress:(void (^)(NSProgress *progress))progress
                       success:(void (^)(id request))success
                       failure:(void (^)(id request))failure;
```
或者 `- (void)requestProgress:(NSProgress *)progress` 的协议方法，下面是一个具体例子：
```
MultiImageUploadApi *multiImageUploadApi = [[MultiImageUploadApi alloc] init];
    multiImageUploadApi.images = @[[UIImage imageNamed:@"test"], [UIImage imageNamed:@"test1"]];
    [multiImageUploadApi startWithBlockProgress:^(NSProgress *progress) {
        NSLog(@"%f", progress.fractionCompleted);
    } success:^(id request) {

    } failure:NULL];
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
__注意，不应该调用`self.responseJSONObject`作为处理数据，请使用`responseObject`来处理__，当实现这个协议方法后，使用 `api1.responseJSONObject` 获取数据时，返回将是 `count` 的值。


### 添加 header

只需要实现`- (NSDictionary *)requestHeaderValue`方法即可，比如

```
- (NSDictionary *)requestHeaderValue{
    return @{@"Accept" : @"application/json"};
}
```
或者添加多个header
```
- (NSDictionary *)requestHeaderValue{
    return @{@"Accept" : @"application/json", @"Accept" : @"application/json; charset=utf-8" : @"Content-Type"};
}
```


### 关于HUD

如何显示 "正在加载"的 HUD，请参考Demo中的 `LCRequestAccessory` 类

1.1.9 版本新增了，是否执行插件的功能，用于隐藏和显示HUD。比如第一次进入页面时调用以下代码请求数据并显示HUD
```
    self.userLikeApi = [[HQUserLikesApi alloc] init];
    HQRequestAccessory *requestAccessory = [[HQRequestAccessory alloc] initWithShowVC:self];
    [self.userLikeApi addAccessory:requestAccessory];
    @weakify(self);
    [self.userLikeApi startWithBlockSuccess:^(__kindof LCBaseRequest *request) {
       //
    } failure:NULL];
```
如果但是如果这时候有上拉加载更多数据功能时，一般情况下都不需要显示HUD，所以
```
- (void)loadMoreData{
    self.userLikeApi.invalidAccessory = YES;
    [self.userLikeApi startWithBlockSuccess:^(HQUserLikesApi *request) {
    //
    } failure:NULL];
}
```
设置`invalidAccessory`属性为YES即可

### 其他

#### Query
某些 POST 请求希望参数不放在 body（或者说是payload）里面，需要用`Query`来附带信息，那么就需要用到 queryArgument 属性，比如
```
unsubscribeChannelApi.queryArgument = @{@"token" : @"token1"};
```
那么`token=token1`就会拼接到 URL 的后面

####原始数据

1.1.3版本提供了一个返回原始数据的属性`rawJSONObject`，用于需要获得原始数据但response又要加工的情况下


## TODO

- [x] response 加工可选功能，比如有些接口返回需要特殊处理，这时候就需要忽略统一的加工方式
- [ ] 替换 Cache 库，由于 [TMCache](https://github.com/tumblr/TMCache) 不在维护
- [x] 适配 [AFNetworking](https://github.com/AFNetworking/AFNetworking/releases) 3.0

##Requirements
* iOS 7 or higher
* ARC

##更新日志

####[Releases](https://github.com/bawn/LCNetwork/releases)

## FAQ
__当请求失败时，如何获取错误信息中的json数据__
```
[self.userLikeApi startWithBlockSuccess:^(__kindof LCBaseRequest *request) {
      //
    } failure:^(__kindof LCBaseRequest *request, NSError *error) {
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
NSLog(@"%@",errResponse);
    }];
```

##License
[MIT](http://mit-license.org/)
