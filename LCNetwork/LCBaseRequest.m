//
//  LCBaseRequest.m
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

#import "LCBaseRequest.h"
#import "LCNetworkAgent.h"
#import "LCNetworkConfig.h"

@interface LCBaseRequest ()

@property (nonatomic, weak) id<LCAPIRequest> child;
@property (nonatomic, strong) NSMutableArray *requestAccessories;
@property (nonatomic, strong) LCNetworkConfig *config;
@property (nonatomic, strong) LCNetworkAgent *agent;

@end

@implementation LCBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(LCAPIRequest)]) {
            _child = (id<LCAPIRequest>)self;
        }
        else {
            NSAssert(NO, @"子类必须要实现APIRequest这个protocol");
        }
        _config = [LCNetworkConfig sharedInstance];
        _agent = [[LCNetworkAgent alloc] init];
      
    }
    return self;
}


- (void)start{
    [self toggleAccessoriesWillStartCallBack];
    [self.agent addRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(LCRequestCompletionBlock)success
                                    failure:(LCRequestFailureBlock)failure{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)startWithBlockSuccess:(LCRequestCompletionBlock)success
                      failure:(LCRequestFailureBlock)failure{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)startWithBlockProgress:(void (^)(NSProgress *))progress
                  success:(LCRequestCompletionBlock)success
                  failure:(LCRequestFailureBlock)failure{
    self.progressBlock = progress;
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}


- (void)startWithBlockSuccess:(LCRequestCompletionBlock)success
                      failure:(LCRequestFailureBlock)failure
                     finished:(LCRequestFinishedBlock)finished{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    self.finishedCompletionBlock = finished;
    [self start];
}

- (void)startWithBlockProgress:(void (^)(NSProgress *))progress
                       success:(LCRequestCompletionBlock)success
                       failure:(LCRequestFailureBlock)failure
                      finished:(LCRequestFinishedBlock)finished{
    self.progressBlock = progress;
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    self.finishedCompletionBlock = finished;
    [self start];
}

- (id)responseJSONObject{
    id responseJSONObject = nil;
    // 统一加工response
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processResponseWithRequest:)]) {
        if (([self.child respondsToSelector:@selector(ignoreUnifiedResponseProcess)] && ![self.child ignoreUnifiedResponseProcess]) ||
            ![self.child respondsToSelector:@selector(ignoreUnifiedResponseProcess)]) {
            responseJSONObject = [self.config.processRule processResponseWithRequest:_responseJSONObject];
            if ([self.child respondsToSelector:@selector(responseProcess:)]){
                responseJSONObject = [self.child responseProcess:responseJSONObject];
            }
            return responseJSONObject;
        }
    }
    
    if ([self.child respondsToSelector:@selector(responseProcess:)]){
        responseJSONObject = [self.child responseProcess:_responseJSONObject];
        return responseJSONObject;
    }
    return _responseJSONObject;
}

- (id)rawJSONObject{
    return _responseJSONObject;
}

- (BOOL)isSuccess{
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(isSuccess:)]) {
        BOOL isFail = [self.config.processRule isSuccess:_responseJSONObject];
        return isFail;
    }
    return YES;
}

- (NSString *)errorMessage{
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(errorMessage:)]) {
        return [self.config.processRule errorMessage:_responseJSONObject];
    }
    return nil;
}

- (NSString *)urlString{
    NSString *baseUrl = nil;
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( [self.child respondsToSelector:@selector(isViceUrl)] && [self.child isViceUrl]) {
        baseUrl = self.config.viceBaseUrl;
    }
    #pragma clang diagnostic pop

    if ([self.child respondsToSelector:@selector(useViceUrl)] && [self.child useViceUrl]){
        baseUrl = self.config.viceBaseUrl;
    }
    else{
        baseUrl = self.config.mainBaseUrl;
    }
    if (baseUrl) {
        if ( [self.child respondsToSelector:@selector(useCustomApiMethodName)] && [self.child useCustomApiMethodName]) {
            return [self.child apiMethodName];
        }
        NSString *urlString = [baseUrl stringByAppendingString:[self.child apiMethodName]];
        if (self.queryArgument && [self.queryArgument isKindOfClass:[NSDictionary class]]) {
            return [urlString stringByAppendingString:[self urlStringForQuery]];
        }
        return urlString;
    }
    return [self.child apiMethodName];
}


- (void)stop{
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [self.agent cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.finishedCompletionBlock = nil;
    self.progressBlock = nil;
}


- (NSString *)urlStringForQuery{
    NSMutableString *urlString = [[NSMutableString alloc] init];
    [urlString appendString:@"?"];
    [self.queryArgument enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [urlString appendFormat:@"%@=%@&", key, obj];
    }];
    [urlString deleteCharactersInRange:NSMakeRange(urlString.length - 1, 1)];
    return [urlString copy];
}


#pragma mark - Request Accessoies

- (void)addAccessory:(id<LCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}
@end



@implementation LCBaseRequest (RequestAccessory)

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

