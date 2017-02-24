//
//  LCBatchRequest.h
//  LCNetwork
//
//  Created by bawn on 7/9/15.
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
#import "LCBaseRequest.h"
@class LCBatchRequest;


typedef void (^LCBatchRequestCompletionBlock)(__kindof LCBatchRequest *request);
typedef void (^LCBatchRequestFailureBlock)(__kindof LCBatchRequest *request, NSError *error);
typedef void (^LCBatchRequestFinishedBlock)(__kindof LCBatchRequest *request, NSError *error);


@protocol LCBatchRequestDelegate <NSObject>

- (void)batchRequestFinished:(LCBatchRequest *)batchRequest;

- (void)batchRequestFailed:(LCBatchRequest *)batchRequest;

@end


@interface LCBatchRequest : NSObject

/**
 *  是否不执行插件，默认是 NO, 也就是说当添加了插件默认是执行，比如有时候需要隐藏HUD
 */
@property (nonatomic, assign) BOOL invalidAccessory;
@property (nonatomic, strong, readonly) NSArray *requestArray;
@property (nonatomic, copy) void (^successCompletionBlock)(LCBatchRequest *);
@property (nonatomic, copy) void (^failureCompletionBlock)(LCBatchRequest *, NSError *);
@property (nonatomic, copy) void (^finishedCompletionBlock)(LCBatchRequest *, NSError *);
@property (nonatomic, weak) id<LCBatchRequestDelegate> delegate;

- (id)initWithRequestArray:(NSArray<LCBaseRequest *> *)requestArray;

/**
 *  开始batch请求
 */
- (void)start;

/**
 *  暂停batch请求
 */
- (void)stop;


/**
 *  block回调方式，已废弃，请使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithCompletionBlockWithSuccess:(LCBatchRequestCompletionBlock)success
                                    failure:(LCBatchRequestFailureBlock)failure
DEPRECATED_MSG_ATTRIBUTE("使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure");

/**
 *  block回调方式
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithBlockSuccess:(LCBatchRequestCompletionBlock)success
                      failure:(LCBatchRequestFailureBlock)failure;

/**
 *  block回调方式
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 *  @param finished 请求完成后的回调
 */
- (void)startWithBlockSuccess:(LCBatchRequestCompletionBlock)success
                      failure:(LCBatchRequestFailureBlock)failure
                     finished:(LCBatchRequestFinishedBlock)finished;



- (void)clearCompletionBlock;

- (void)addAccessory:(id<LCRequestAccessory>)accessory;


@end


@interface LCBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

