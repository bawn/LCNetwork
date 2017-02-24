//
//  LCBatchRequest.m
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

#import "LCBatchRequest.h"
#import "LCBaseRequest.h"
#import "LCBatchRequestAgent.h"

@interface LCBatchRequest () <LCRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestAccessories;
@property (nonatomic) NSInteger finishedCount;
@property (nonatomic, strong) NSArray *requestArray;

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



- (void)start{
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


- (void)stop{
    [self toggleAccessoriesWillStopCallBack];
    _delegate = nil;
    [self clearRequest];
    [self toggleAccessoriesDidStopCallBack];
    [[LCBatchRequestAgent sharedInstance] removeBatchRequest:self];
}

- (void)requestDidStop{
    [self clearCompletionBlock];
    [self toggleAccessoriesDidStopCallBack];
    self.finishedCount = 0;
    self.requestArray = nil;
    [[LCBatchRequestAgent sharedInstance] removeBatchRequest:self];
}


- (void)startWithCompletionBlockWithSuccess:(LCBatchRequestCompletionBlock)success
                                    failure:(LCBatchRequestFailureBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure finished:NULL];
    [self start];
}

- (void)startWithBlockSuccess:(LCBatchRequestCompletionBlock)success
                      failure:(LCBatchRequestFailureBlock)failure{
    [self setCompletionBlockWithSuccess:success failure:failure finished:NULL];
    [self start];
}

- (void)startWithBlockSuccess:(LCBatchRequestCompletionBlock)success
                      failure:(LCBatchRequestFailureBlock)failure
                     finished:(LCBatchRequestFinishedBlock)finished{
    [self setCompletionBlockWithSuccess:success failure:failure finished:finished];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(LCBatchRequestCompletionBlock)success
                              failure:(LCBatchRequestFailureBlock)failure
                              finished:(LCBatchRequestFinishedBlock)finished{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    self.finishedCompletionBlock = finished;
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.finishedCompletionBlock = nil;
}


- (void)dealloc {
    [self clearRequest];
}

#pragma mark - Network Request Delegate


- (void)requestSuccess:(LCBaseRequest *)request{
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [_delegate batchRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        if (_finishedCompletionBlock) {
            _finishedCompletionBlock(self, nil);
        }
        [self requestDidStop];
    }
}

- (void)requestFailed:(LCBaseRequest *)request error:(NSError *)error{
    [self toggleAccessoriesWillStopCallBack];
    for (LCBaseRequest *req in _requestArray) {
        [req stop];
    }
    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
        [_delegate batchRequestFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self, error);
    }
    if (_finishedCompletionBlock) {
        _finishedCompletionBlock(self, error);
    }
    [self requestDidStop];
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
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
                [accessory requestWillStart:self];
            }
        }
    }
}

- (void)toggleAccessoriesWillStopCallBack {
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
                [accessory requestWillStop:self];
            }
        }
    }
}

- (void)toggleAccessoriesDidStopCallBack {
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
                [accessory requestDidStop:self];
            }
        }
    }
}

@end

