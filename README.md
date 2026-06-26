# LCNetwork

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/LCNetwork.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)
[![Support](https://img.shields.io/badge/support-iOS7+-blue.svg?style=flat)](https://www.apple.com/nl/ios/)

This is a wrapper around `AFNetworking`, inspired by the implementation style of [YTKNetwork](https://github.com/yuantiku/YTKNetwork).
API classes are constrained by `@protocol`, which makes API creation and usage clearer. Compatible with AFNetworking 3.x.

If the demo crashes, please delete the app and run it again. Thanks to [zdoz](http://api.zdoz.net/) for providing a free test API.

## Features

1. Supports both `block` and `delegate` callbacks
2. Supports configuring primary and secondary server addresses
3. ~Supports `response` caching based on [TMCache](https://github.com/tumblr/TMCache)~
4. Supports unified `argument` processing
5. Supports unified `response` processing
6. Supports sending multiple requests at the same time and configuring their callbacks together
7. Supports conveniently sending dependent network requests
8. Supports displaying a HUD in a plugin-like way
9. Supports real-time request progress

__A final example of calling an API request inside `ViewController` is shown below__

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


## Integration

CocoaPods:
```
pod 'LCNetwork'
```

## Usage
### Unified configuration


```
LCNetworkConfig *config = [LCNetworkConfig sharedInstance];
config.mainBaseUrl = @"http://api.zdoz.net/"; // main server address
config.viceBaseUrl = @"https://api.zdoz.net/"; // secondary server address
```

### Creating an API request class
Each request needs a corresponding class. The benefit is that all request-specific information lives inside the API class and is no longer exposed at the controller layer.

To create an API class, inherit from `LCBaseRequest` and conform to the `LCAPIRequest` protocol. The following is the most basic API class setup.

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

// API path
- (NSString *)apiMethodName{
    return @"getweather.aspx";
}

// Request method
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

@end
```
`- (NSString *)apiMethodName` and `- (LCRequestMethod)requestMethod` are `@required` methods, so they must be implemented. This reduces the chance of crashes caused by missing methods.


### Parameter setup

Request parameters can be set externally, for example:
```
Api2 *api2 = [[Api2 alloc] init];
api2.requestArgument = @{
                          @"lat" : @"34.345",
                          @"lng" : @"113.678"
                        };
```
If you do not want to expose parameter keys outside the API class, you can also define a custom initializer inside the API class, for example:

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
Using `self.requestArgument = @{@"lat" : lat, lng" : lng}` directly inside the initializer is not ideal. See [Tang Qiao](http://blog.devtang.com/blog/2011/08/10/do-not-use-accessor-in-init-and-dealloc-method/) and [jymn_chen](http://blog.csdn.net/jymn_chen/article/details/25000575) for details. If you want to fully avoid this issue, please refer to the demo implementation.


### Unified handling of `argument` and `response`

This requires another protocol, `<LCProcessProtocol>`. For example, if every request needs a version parameter:

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

Or, if you need to process JSON like the following, where the server response always includes `result` and `ok` keys:
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
Then you need to implement `- (id)processResponseWithRequest:(id)response`:

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
That means when you use `api1.responseJSONObject`, the returned value is the data under `result`, or an error object.

`LCProcessProtocol` also defines another method for marking whether a request succeeded. The following response represents success because the value of `ok` is `true`:

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

Of course, not every API uses the `ok` field to indicate success, so this method is used to define custom success conditions:

```
- (BOOL)isSuccess:(id)response{
    return [response[@"ok"] boolValue];
}
```

Then `api1.isSuccess` can be used to determine whether the request succeeded.

```
LCProcessFilter *filter = [[LCProcessFilter alloc] init];
config.processRule = filter;
```

If you do not want a particular request's response to go through the unified processing flow, you can implement the following in the request subclass:
```
- (BOOL)ignoreUnifiedResponseProcess{
    return YES;
}
```
In that case, `responseJSONObject` will contain the raw data.

### multipart/form-data

When uploading images or other files, `multipart/form-data` is usually needed. You only need to implement the `- (AFConstructingBlock)constructingBodyBlock;` protocol method, for example:
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
For multi-image uploads, you may also want to track progress. Starting from LCNetwork 1.1.0, a progress callback is available. Just call:
```
 (void)startWithBlockProgress:(void (^)(NSProgress *progress))progress
                       success:(void (^)(id request))success
                       failure:(void (^)(id request))failure;
```
Or implement the `- (void)requestProgress:(NSProgress *)progress` protocol method. Here is a concrete example:
```
MultiImageUploadApi *multiImageUploadApi = [[MultiImageUploadApi alloc] init];
    multiImageUploadApi.images = @[[UIImage imageNamed:@"test"], [UIImage imageNamed:@"test1"]];
    [multiImageUploadApi startWithBlockProgress:^(NSProgress *progress) {
        NSLog(@"%f", progress.fractionCompleted);
    } success:^(id request) {

    } failure:NULL];
```

### Further response processing

When the response looks like this:
```
{
  "result": {
      "_id": "564a931dbbb03c7002a2c0f3",
      "name": "clover",
      "count": 10
    },

  "ok": true,
  "message" : "success"
}
```
If the response has already been processed in a unified way, for example by returning the data inside `result` after success, the returned value may still be an `NSDictionary`, which might not meet your needs. In that case, it is better to let the `LCBaseRequest` subclass process the data again. For example, if you need to extract the `count` value directly, just implement `- (id)responseProcess:(id)responseObject;` as follows:

```
- (id)responseProcess:(id)responseObject{
    return responseObject[@"count"];
}
```
__Note: do not use `self.responseJSONObject` when processing the data. Use `responseObject` instead.__ After implementing this protocol method, `api1.responseJSONObject` will return the value of `count`.

### Adding headers

You only need to implement `- (NSDictionary *)requestHeaderValue`, for example:

```
- (NSDictionary *)requestHeaderValue{
    return @{@"Accept" : @"application/json"};
}
```
Or add multiple headers:
```
- (NSDictionary *)requestHeaderValue{
    return @{@"Accept" : @"application/json", @"Content-Type" : @"application/json; charset=utf-8"};
}
```

### How to use LCQueueRequest

Use this when each request starts at an unpredictable time, but you still need to know when all of them have finished.

For example: a user uploads multiple images, and after each image upload the server returns an image URL. When the user finally taps the "Done" button, those URLs are submitted to the server. Since each upload may start at a different time, some uploads may still be in progress when the user taps "Done". In that case, you need to wait until all upload requests have completed.

Initialize `LCQueueRequest`. This class also supports adding a HUD (loading view):
```
    self.queueRequest = [[LCQueueRequest alloc] init];
    HQRequestAccessory *accessory = [[HQRequestAccessory alloc] initWithViewController:self];
    [self.queueRequest addAccessory:accessory];
```

When uploading each image, use `- (void)addRequest:(LCBaseRequest *)request` to add the request to the concurrent queue:
```
- (void)uploadImage:(UIImage *)image imageInfo:(HQImageInfo *)imageInfo{
    HQSingleImageUploadApi *uploadApi = [[HQSingleImageUploadApi alloc] init];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.6);
    uploadApi.uploadImageData = imageData;

    [uploadApi startWithBlockSuccess:^(__kindof LCBaseRequest *request) {
        //
    } failure:NULL];

    [self.queueRequest addRequest:uploadApi];
}
```

Finally, when the user taps the "Done" button, execution will wait until all requests in the queue have completed. The HUD (loading view) will also be displayed correctly.
```
- (IBAction)doneButtonAction:(id)sender{
    [self.queueRequest allComplete:^{
        //
    }];
}
```

### About the HUD

To show a "loading" HUD, please refer to the `LCRequestAccessory` class in the demo.

Version 1.1.9 added the ability to enable or disable accessories, which can be used to hide or show the HUD. For example, when entering a page for the first time, you can request data and show the HUD with the following code:
```
    self.userLikeApi = [[HQUserLikesApi alloc] init];
    HQRequestAccessory *requestAccessory = [[HQRequestAccessory alloc] initWithShowVC:self];
    [self.userLikeApi addAccessory:requestAccessory];
    @weakify(self);
    [self.userLikeApi startWithBlockSuccess:^(__kindof LCBaseRequest *request) {
       //
    } failure:NULL];
```
If you also have a "load more" feature at this time, you usually do not need to show the HUD, so:
```
- (void)loadMoreData{
    self.userLikeApi.invalidAccessory = YES;
    [self.userLikeApi startWithBlockSuccess:^(HQUserLikesApi *request) {
    //
    } failure:NULL];
}
```
Set `invalidAccessory` to `YES`.

### Others

#### Query
Some POST requests need parameters to be sent outside the body (or payload). In that case, use `Query` to attach the information through the `queryArgument` property, for example:
```
unsubscribeChannelApi.queryArgument = @{@"token" : @"token1"};
```
Then `token=token1` will be appended to the end of the URL.

#### Raw data

Version 1.1.3 introduced a `rawJSONObject` property for cases where you need the raw data while still processing the response.


## TODO

- [x] Optional response processing, for example when some API responses require special handling and should skip the unified processing flow
- [x] ~Replace the cache library, since [TMCache](https://github.com/tumblr/TMCache) is no longer maintained~
- [x] Compatible with [AFNetworking](https://github.com/AFNetworking/AFNetworking/releases) 3.0

## Requirements
* iOS 7 or higher
* ARC

## Changelog

#### [Releases](https://github.com/bawn/LCNetwork/releases)

## FAQ
__How do I get JSON data from the error info when a request fails?__
```
[self.userLikeApi startWithBlockSuccess:^(__kindof LCBaseRequest *request) {
      //
    } failure:^(__kindof LCBaseRequest *request, NSError *error) {
        NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
NSLog(@"%@",errResponse);
    }];
```

## License
[MIT](http://mit-license.org/)
