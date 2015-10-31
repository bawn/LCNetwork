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


##集成

Cocoapods:
```
pod 'LCNetwork'
```

##使用
###统一配置

`LCNetworkConfig`类用于配置服务器地址和是否显示请求log
```
LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
config.mainBaseUrl = @"http://api.zdoz.net/";// 设置主服务器地址
config.viceBaseUrl = @"https://api.zdoz.net/";// 设置副服务器地址
config.logEnabled = YES;// 是否打印log信息
```

###参数和response的加工
`LCProcessProtocol`协议中包含了两个方法:
参数加工，适用于需要统一配置参数，比如参数加密或者加入某个统一的参数
```
- (NSDictionary *) processArgumentWithRequest:(LCBaseRequest *)request;
```
和
response加工，比如服务器返回的数据的格式都是 data = {};，统一把data中的数据取出来使用
```
- (id) processResponseWithRequest:(id)response;
```
此时只需要创建一个遵守`LCProcessProtocol`协议的类，比如`LCProcessFilter`
```
LCProcessFilter *filter = [[LCProcessFilter alloc] init];
config.processRule = filter;
```

###创建接口调用类
是的，每个接口调用都需要一个类去执行，这个类必须是`LCBaseRequest`的子类，而且必须遵守`LCAPIRequest`协议
```
@interface Api1 : LCBaseRequest<LCAPIRequest>
```
需要实现的方法和遵守的属性：
```
// 参数属性
@synthesize requestArgument;

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}
```
###调用
```
Api1 *api1 = [[Api1 alloc] init];
api1.requestArgument = @{@"cityName" : @"杭州"};
[api1 startWithCompletionBlockWithSuccess:^(Api1 *api1) {
  ...
} failure:^(id request) {
  ...
    }];
```
##更多信息
参考自带的 Demo 或是我的[博客](http://bawn.github.io/ios/afnetworking/2015/08/10/LCNetwork.html)

##Requirements
* iOS 6 or higher
* ARC


##License
```
The MIT License (MIT)

Copyright (c) 2015 Bawn

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
