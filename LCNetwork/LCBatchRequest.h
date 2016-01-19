//
//  LCBatchRequest.h
//  LCNetwork
//
//  Created by bawn on 7/9/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCBaseRequest.h"
@class LCBatchRequest;

@protocol LCBatchRequestDelegate <NSObject>

- (void)batchRequestFinished:(LCBatchRequest *)batchRequest;

- (void)batchRequestFailed:(LCBatchRequest *)batchRequest;

@end


@interface LCBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (nonatomic, copy) void (^successCompletionBlock)(LCBatchRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(LCBatchRequest *);

@property (nonatomic, weak) id<LCBatchRequestDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *requestAccessories;


- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;


/**
 *  block回调方式，已废弃，请使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithCompletionBlockWithSuccess:(void (^)(LCBatchRequest *request))success
                                    failure:(void (^)(LCBatchRequest *request))failure
DEPRECATED_MSG_ATTRIBUTE("使用 - (void)startWithBlockSuccess:(void (^)(id request))success failure:(void (^)(id request))failure");

/**
 *  block回调方式
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)startWithBlockSuccess:(void (^)(LCBatchRequest *request))success
                      failure:(void (^)(LCBatchRequest *request))failure;



- (void)clearCompletionBlock;

- (void)addAccessory:(id<LCRequestAccessory>)accessory;


@end


@interface LCBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

