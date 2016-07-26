//
//  LCChainRequest.h
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


#import <Foundation/Foundation.h>
#import "LCBaseRequest.h"

@class LCChainRequest;

@protocol LCChainRequestDelegate <NSObject>

@optional

- (void)chainRequestFinished:(LCChainRequest *)chainRequest;

- (void)chainRequestFailed:(LCChainRequest *)chainRequest failedBaseRequest:(LCBaseRequest*)request;

@end

typedef void (^LCChainCallback)(LCChainRequest *chainRequest, __kindof LCBaseRequest *request);

@interface LCChainRequest : NSObject

/**
 *  是否不执行插件，默认是 NO, 也就是说当添加了插件默认是执行，比如有时候需要隐藏HUD
 */
@property (nonatomic, assign) BOOL invalidAccessory;
@property (nonatomic, weak) id<LCChainRequestDelegate> delegate;

/**
 *  开始Chain请求
 */
- (void)start;

/**
 *  暂停Chain请求
 */
- (void)stop;

- (void)addRequest:(LCBaseRequest<LCAPIRequest> *)request callback:(LCChainCallback)callback;

- (NSArray *)requestArray;

- (void)addAccessory:(id<LCRequestAccessory>)accessory;

@end


@interface LCChainRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end


