//
//  LCNetworkConfig.h
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

@class LCBaseRequest;
@class AFSecurityPolicy;

@protocol LCProcessProtocol <NSObject>

@optional
/**
 *  用于统一加工参数，返回处理后的参数值
 *
 *  @param argument 参数
 *  @param queryArgument query 信息，详情查看 https://github.com/bawn/LCNetwork#query
 *
 *  @return 处理后的参数
 */
- (NSDictionary *)processArgumentWithRequest:(NSDictionary *)argument query:(NSDictionary *)queryArgument;
/**
 *  用于统一加工response，返回处理后response
 *
 *  @param response response
 *
 *  @return 处理后的response
 */
- (id)processResponseWithRequest:(id)response;

/**
 *  请求中统一添加Header
 *
 *  @return Header NSDictionary
 */
- (NSDictionary *)requestHeaderValue;


@end

@interface LCNetworkConfig : NSObject

+ (LCNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *mainBaseUrl;// 主url
@property (nonatomic, strong) NSString *viceBaseUrl;// 副url
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, strong) id <LCProcessProtocol> processRule;

@end
