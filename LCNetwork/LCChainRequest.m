//
//  LCChainRequest.m
//  LCNetworkDemo
//
//  Created by bawn on 2/16/16.
//  Copyright © 2016 beike. All rights reserved.
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

#import "LCChainRequest.h"
#import "LCChainRequestAgent.h"

@interface LCChainRequest()<LCRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestAccessories;
@property (nonatomic, strong) NSMutableArray *requestArray;
@property (nonatomic, strong) NSMutableArray *requestCallbackArray;
@property (nonatomic, assign) NSUInteger nextRequestIndex;
@property (nonatomic, strong) LCChainCallback emptyCallback;

@end

@implementation LCChainRequest

- (id)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _emptyCallback = ^(LCChainRequest *chainRequest, LCBaseRequest *baseRequest) {
            // do nothing
        };
    }
    return self;
}

- (void)start {
    if (_nextRequestIndex > 0) {
        NSLog(@"Error! Chain request has already started.");
        return;
    }
    
    if ([_requestArray count] > 0) {
        [self toggleAccessoriesWillStartCallBack];
        [self startNextRequest];
        [[LCChainRequestAgent sharedInstance] addChainRequest:self];
    } else {
        NSLog(@"Error! Chain request array is empty.");
    }
}

- (NSArray *)requestArray{
    return [self.requestArray copy];
}

- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    [self clearRequest];
    [[LCChainRequestAgent sharedInstance] removeChainRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)requestDidStop{
    [self toggleAccessoriesDidStopCallBack];
    self.nextRequestIndex = 0;
    [self.requestCallbackArray removeAllObjects];
    [_requestArray removeAllObjects];
    [[LCChainRequestAgent sharedInstance] removeChainRequest:self];
}


- (void)addRequest:(LCBaseRequest *)request callback:(LCChainCallback)callback {
    [_requestArray addObject:request];
    if (callback != nil) {
        [_requestCallbackArray addObject:callback];
    } else {
        [_requestCallbackArray addObject:_emptyCallback];
    }
}


- (BOOL)startNextRequest {
    if (_nextRequestIndex < [_requestArray count]) {
        LCBaseRequest *request = _requestArray[_nextRequestIndex];
        _nextRequestIndex++;
        request.delegate = self;
        [request start];
        return YES;
    }
    else {
        return NO;
    }
}

- (void)dealloc{
    [self clearRequest];
}

#pragma mark - Network Request Delegate


- (void)requestSuccess:(LCBaseRequest *)request{
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    LCChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if ([self startNextRequest] == NO) {
        [self toggleAccessoriesWillStopCallBack];
        if ([_delegate respondsToSelector:@selector(chainRequestFinished:)]) {
            [_delegate chainRequestFinished:self];
        }
        [self requestDidStop];
    }
}

- (void)requestFailed:(LCBaseRequest *)request error:(NSError *)error{
    [self toggleAccessoriesWillStopCallBack];
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:failedBaseRequest:)]) {
        [_delegate chainRequestFailed:self failedBaseRequest:request];
    }
    [self requestDidStop];
}

- (void)clearRequest {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < [_requestArray count]) {
        LCBaseRequest *request = _requestArray[currentRequestIndex];
        [request stop];
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}

#pragma mark - Request Accessoies

- (void)addAccessory:(id<LCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}


@end

@implementation LCChainRequest (RequestAccessory)

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

