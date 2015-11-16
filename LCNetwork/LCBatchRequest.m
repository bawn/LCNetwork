//
//  LCBatchRequest.m
//  LCNetwork
//
//  Created by bawn on 7/9/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import "LCBatchRequest.h"
#import "LCBaseRequest.h"
#import "LCBatchRequestAgent.h"

@interface LCBatchRequest () <LCRequestDelegate>

@property (nonatomic) NSInteger finishedCount;

@end

@implementation LCBatchRequest


- (id)initWithRequestArray:(NSArray *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        for (LCBatchRequest * req in _requestArray) {
            if (![req isKindOfClass:[LCBaseRequest class]]) {
                NSLog(@"Error, request item must be LCBaseRequest instance.");
                return nil;
            }
        }
    }
    return self;
}


- (void)start {
    if (_finishedCount > 0) {
        NSLog(@"Error! Batch request has already started.");
        return;
    }
    [[LCBatchRequestAgent sharedInstance] addBatchRequest:self];
    [self toggleAccessoriesWillStartCallBack];
    for (LCBaseRequest * req in _requestArray) {
        req.delegate = self;
        [req start];
    }
}


- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    _delegate = nil;
    [self clearRequest];
    [self toggleAccessoriesDidStopCallBack];
    [[LCBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(LCBatchRequest *batchRequest))success
                                    failure:(void (^)(LCBatchRequest *batchRequest))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(LCBatchRequest *batchRequest))success
                              failure:(void (^)(LCBatchRequest *batchRequest))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}


- (void)dealloc {
    [self clearRequest];
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(LCBaseRequest *)request {
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [_delegate batchRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
        [self toggleAccessoriesDidStopCallBack];
    }
}

- (void)requestFailed:(LCBaseRequest *)request {
    [self toggleAccessoriesWillStopCallBack];
    // Stop
    for (LCBaseRequest *req in _requestArray) {
        [req stop];
    }
    // Callback
    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
        [_delegate batchRequestFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self);
    }
    // Clear
    [self clearCompletionBlock];
    
    [self toggleAccessoriesDidStopCallBack];
    [[LCBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)clearRequest {
    for (LCBaseRequest * req in _requestArray) {
        [req stop];
    }
    [self clearCompletionBlock];
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<LCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end


@implementation LCBatchRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack {
    for (id<LCRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
            [accessory requestWillStart:self];
        }
    }
}

- (void)toggleAccessoriesWillStopCallBack {
    for (id<LCRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
            [accessory requestWillStop:self];
        }
    }
}

- (void)toggleAccessoriesDidStopCallBack {
    for (id<LCRequestAccessory> accessory in self.requestAccessories) {
        if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
            [accessory requestDidStop:self];
        }
    }
}

@end

