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

// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(LCBatchRequest *batchRequest))success
                                    failure:(void (^)(LCBatchRequest *batchRequest))failure;

- (void)clearCompletionBlock;

- (void)addAccessory:(id<LCRequestAccessory>)accessory;


@end


@interface LCBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

