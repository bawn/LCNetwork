//
//  LCBaseRequest.h
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>


@class LCBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^LCRequestCompletionBlock)(__kindof LCBaseRequest *request);
typedef void (^LCRequestFailureBlock)(__kindof LCBaseRequest *request, NSError *error);
typedef void (^LCRequestFinishedBlock)(__kindof LCBaseRequest *request, NSError *error);

typedef NS_ENUM(NSInteger , LCRequestMethod) {
    LCRequestMethodGet = 0,
    LCRequestMethodPost,
    LCRequestMethodHead,
    LCRequestMethodPut,
    LCRequestMethodDelete,
    LCRequestMethodPatch
};

typedef NS_ENUM(NSInteger , LCRequestSerializerType) {
    LCRequestSerializerTypeHTTP = 0,
    LCRequestSerializerTypeJSON,
};

/*--------------------------------------------*/
@protocol LCAPIRequest <NSObject>

@required

/**
 *  接口地址
 *
 *  @return 接口地址
 */
- (NSString *)apiMethodName;
/**
 *  请求方式，包括Get、Post、Head、Put、Delete、Patch，具体查看 LCRequestMethod
 *
 *  @return 请求方式
 */
- (LCRequestMethod)requestMethod;

@optional

// 是否使用副Url(旧版)
@property (nonatomic, assign, getter = isViceUrl) BOOL viceUrl DEPRECATED_MSG_ATTRIBUTE("使用 - (BOOL)useViceUrl");

/**
 *  可以使用两个根地址，比如可能会用到 CDN 地址、https之类的
 *
 *  @return 是否使用副Url
 */
- (BOOL)useViceUrl;


/**
 *  自定义超时时间
 *
 *  @return 超时时间
 */
- (NSTimeInterval)requestTimeoutInterval;

/**
 *  multipart 数据
 *
 *  @return 用于 multipart 的数据block
 */
- (AFConstructingBlock)constructingBodyBlock;


// response 处理(旧版)
- (id)responseProcess DEPRECATED_MSG_ATTRIBUTE("使用 - (id)responseProcess:");

/**
 *  处理responseJSONObject，当外部访问 self.responseJSONObject 的时候就会返回这个方法处理后的数据
 *
 *  @param responseObject 输入的 responseObject ，在方法内切勿使用 self.responseJSONObject
 *
 *  @return 处理后的responseJSONObject
 */
- (id)responseProcess:(id)responseObject;

/**
 *  是否忽略统一的参数加工
 *
 *  @return 返回 YES，那么 self.responseJSONObject 将返回原始的数据
 */
- (BOOL)ignoreUnifiedResponseProcess;

/**
 *  是否使用自定义的接口地址，也就是不会使用 mainBaseUrl 或 viceBaseUrl，这时候在 apiMethodName 就可以是用自定义的接口地址了
 *
 *  @return 是否使用自定义的接口地址
 */
- (BOOL)useCustomApiMethodName;

/**
 *  服务端数据接收类型，比如 LCRequestSerializerTypeJSON 用于 post json 数据
 *
 *  @return 服务端数据接收类型
 */
- (LCRequestSerializerType)requestSerializerType;


/**
 *  当数据返回 null 时是否删除这个字段的值，也就是为 nil，默认YES，具体查看http://honglu.me/2015/04/11/json%E4%B8%AD%E5%A4%B4%E7%96%BC%E7%9A%84null/
 *
 *  @return YES/NO
 */
- (BOOL)removesKeysWithNullValues;


/**
 *  添加请求 Header，比如@{@"Accept" : @"application/json"}，那么 application/json 对应的是 Value，Accept对应的是 HTTPHeaderField
 *
 *  @return NSDictionary
 */
- (NSDictionary *)requestHeaderValue;


/**
 *  缓存策略
 *
 *  @return NSURLRequestCachePolicy
 */
- (NSURLRequestCachePolicy)cachePolicy;



@end


/*--------------------------------------------*/
@class LCBaseRequest;
@protocol LCRequestDelegate <NSObject>

@optional

- (void)requestSuccess:(LCBaseRequest *)request;
- (void)requestFinished:(LCBaseRequest *)request error:(NSError *)error;
- (void)requestFailed:(LCBaseRequest *)request error:(NSError *)error;
- (void)requestProgress:(NSProgress *)progress;

@end
/*--------------------------------------------*/

@protocol LCRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end


@interface LCBaseRequest : NSObject

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) id requestArgument;

/**
 *  用于 POST 情况下，拼接参数请求，而不是放在body里面
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *queryArgument;

@property (nonatomic, weak) id<LCRequestDelegate> delegate;
@property (nonatomic, weak, readonly) id<LCAPIRequest> child;

/**
 *  当通过get方式访问 responseJSONObject 时就会得到加工后的数据
 */

@property (nonatomic, strong) id responseJSONObject;
/**
 *  接口返回的原始数据
 */

@property (nonatomic, strong, readonly) id rawJSONObject;

/**
 *  是否不执行插件，默认是 NO, 也就是说当添加了插件默认是执行，比如有时候需要隐藏HUD
 */
@property (nonatomic, assign) BOOL invalidAccessory;



/**
 判断接口返回是否成功，此成功代表的是接口是否成功处理
 {
	"result": {
 
	},
	"ok": true
 }
 此处，ok 就代表是否成功
 
 具体的逻辑请实现 LCNetworkConfig 中的 - (BOOL)isSuccess:(id)responses; 方法
 */
@property (nonatomic, assign, readonly) BOOL isSuccess;


/**
 接口请求出错返回的消息
 */
@property (nonatomic, assign, readonly) NSString * errorMessage;

@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong, readonly) NSString *urlString;
@property (nonatomic, strong, readonly) NSMutableArray *requestAccessories;
@property (nonatomic, copy) void (^successCompletionBlock)(LCBaseRequest *);
@property (nonatomic, copy) void (^failureCompletionBlock)(LCBaseRequest *, NSError *error);
@property (nonatomic, copy) void (^finishedCompletionBlock)(LCBaseRequest *, NSError *error);
@property (nonatomic, copy) void (^progressBlock)(NSProgress * progress);

/**
 *  开始请求，使用 detegate 方式使用这个方法
 */
- (void)start;

/**
 *  停止请求
 */
- (void)stop;


/**
 *  block回调方式，已废弃，请使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithCompletionBlockWithSuccess:(LCRequestCompletionBlock)success
                                    failure:(LCRequestFailureBlock)failure
                                    DEPRECATED_MSG_ATTRIBUTE("使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure");

/**
 *  block回调方式
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithBlockSuccess:(LCRequestCompletionBlock)success
                      failure:(LCRequestFailureBlock)failure;


/**
 block回调方式

 @param success 成功回调
 @param failure 失败回调
 @param finished 请求完成后的回调
 */
- (void)startWithBlockSuccess:(LCRequestCompletionBlock)success
                      failure:(LCRequestFailureBlock)failure
                     finished:(LCRequestFinishedBlock)finished;



/**
 *  block回调方式
 *
 *  @param progress 进度回调
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)startWithBlockProgress:(void (^)(NSProgress *progress))progress
                       success:(LCRequestCompletionBlock)success
                       failure:(LCRequestFailureBlock)failure;


/**
 block回调方式

 @param progress 进度回调
 @param success 成功回调
 @param failure 失败回调
 @param finished 请求完成后的回调
 */
- (void)startWithBlockProgress:(void (^)(NSProgress *progress))progress
                       success:(LCRequestCompletionBlock)success
                       failure:(LCRequestFailureBlock)failure
                      finished:(LCRequestFinishedBlock)finished;


/**
 *  一般用于显示和隐藏 HUD
 *
 *  @param accessory 插件
 */
- (void)addAccessory:(id<LCRequestAccessory>)accessory;

@end


@interface LCBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end
