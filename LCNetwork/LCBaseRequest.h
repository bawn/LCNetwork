//
//  LCBaseRequest.h
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFURLRequestSerialization.h"
@class AFHTTPRequestOperation;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

typedef NS_ENUM(NSInteger , LCRequestMethod) {
    LCRequestMethodGet = 0,
    LCRequestMethodPost,
    LCRequestMethodHead,
    LCRequestMethodPut,
    LCRequestMethodDelete,
    LCRequestMethodPatch
};

/*--------------------------------------------*/
@protocol LCAPIRequest <NSObject>

@required
// 接口地址
- (NSString *)apiMethodName;
// 请求方式
- (LCRequestMethod)requestMethod;

@optional

// 是否使用副Url(旧版)
@property (nonatomic, assign, getter = isViceUrl) BOOL viceUrl DEPRECATED_MSG_ATTRIBUTE("Use - (BOOL)useViceUrl");

// 是否使用副Url
- (BOOL)useViceUrl;

// 是否缓存数据 response 数据
- (BOOL)cacheResponse;

// 是否缓存数据 response 数据(旧版)
- (BOOL)withoutCache DEPRECATED_MSG_ATTRIBUTE("Use - (BOOL)cacheResponse");

// 超时时间
- (NSTimeInterval)requestTimeoutInterval;

// 用于Body数据的block
- (AFConstructingBlock)constructingBodyBlock;

// json数据类型验证
- (id)jsonValidator;

// response 处理(旧版)
- (id)responseProcess DEPRECATED_MSG_ATTRIBUTE("Use - (id)responseProcess:");

/**
 *  处理responseJSONObject，当外部访问 self.responseJSONObject 的时候就会返回这个方法处理后的数据
 *
 *  @param responseObject 输入的 responseObject ，在方法内切勿使用 self.responseJSONObject
 *
 *  @return 处理后的responseJSONObject
 */
- (id)responseProcess:(id)responseObject;

@end

/*--------------------------------------------*/
@class LCBaseRequest;
@protocol LCRequestDelegate <NSObject>

- (void)requestFinished:(LCBaseRequest *)request;
- (void)requestFailed:(LCBaseRequest *)request;

@end
/*--------------------------------------------*/

@protocol LCRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end


@interface LCBaseRequest : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong) NSDictionary *requestArgument;
@property (nonatomic, weak) id<LCRequestDelegate> delegate;
@property (nonatomic, weak, readonly) id<LCAPIRequest> child;
@property (nonatomic, strong, readonly) id responseJSONObject;
@property (nonatomic, strong, readonly) id cacheJson;
@property (nonatomic, strong, readonly) NSMutableArray *requestAccessories;
@property (nonatomic, copy) void (^successCompletionBlock)(LCBaseRequest *);
@property (nonatomic, copy) void (^failureCompletionBlock)(LCBaseRequest *);


- (void)start;
- (void)stop;


// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(id request))success
                                    failure:(void (^)(id request))failure;

- (void)clearCompletionBlock;
- (BOOL)statusCodeValidator;


- (void)addAccessory:(id<LCRequestAccessory>)accessory;

@end


@interface LCBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;


@end

