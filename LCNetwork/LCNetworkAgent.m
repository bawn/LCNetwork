//
//  LCNetworkAgent.m
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

#import "LCNetworkAgent.h"
#import "LCNetworkConfig.h"
#import "LCBaseRequest.h"
#import "AFNetworking.h"
#import "LCBaseRequest+Internal.h"

@interface LCNetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestsRecord;
@property (nonatomic, strong) LCNetworkConfig *config;

@end

@implementation LCNetworkAgent


- (id)init {
    self = [super init];
    if (self) {
        _config = [LCNetworkConfig sharedInstance];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.securityPolicy = _config.securityPolicy;
        _manager = [AFHTTPSessionManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}


- (void)addRequest:(LCBaseRequest <LCAPIRequest>*)request {

    NSString *url = request.urlString;
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", nil];
    
    if ([request.child respondsToSelector:@selector(removesKeysWithNullValues)]) {
        serializer.removesKeysWithNullValues = [request.child removesKeysWithNullValues];
    }
    self.manager.responseSerializer = serializer;
    NSDictionary *argument = request.requestArgument;
    // 检查是否有统一的参数加工
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processArgumentWithRequest:query:)]) {
        argument = [self.config.processRule processArgumentWithRequest:request.requestArgument query:request.queryArgument];
    }
    
    
    if ([request.child respondsToSelector:@selector(requestSerializerType)]) {
        if ([request.child requestSerializerType] == LCRequestSerializerTypeHTTP) {
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        else{
            self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
    }
    
    
    // 检查是否有统一的Header添加
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(requestHeaderValue)]) {
        NSDictionary<NSString *, NSString *> *headerValue = [self.config.processRule requestHeaderValue];
        if ([headerValue isKindOfClass:[NSDictionary class]]){
            [headerValue enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    if ([request.child respondsToSelector:@selector(requestHeaderValue)]) {
        NSDictionary<NSString *, NSString *> *headerValue = [request.child requestHeaderValue];
        if ([headerValue isKindOfClass:[NSDictionary class]]){
            [headerValue enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [self.manager.requestSerializer setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(authorizationHeaderFieldArray)]) {
        NSArray *authorizationHeaderFieldArray = [self.config.processRule authorizationHeaderFieldArray];
        if ([authorizationHeaderFieldArray isKindOfClass:[NSArray class]]){
            [self.manager.requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject password:authorizationHeaderFieldArray.lastObject];
        }
    }
    
    // 是否使用自定义超时时间
    if ([request.child respondsToSelector:@selector(requestTimeoutInterval)]) {
        self.manager.requestSerializer.timeoutInterval = [request.child requestTimeoutInterval];
    }
    else{
        self.manager.requestSerializer.timeoutInterval = 60.0;
    }
    
    if ([request.child respondsToSelector:@selector(cachePolicy)]) {
        [self.manager.requestSerializer setCachePolicy:[request.child cachePolicy]];
    }
    else{
        [self.manager.requestSerializer setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    
    if ([request.child requestMethod] == LCRequestMethodGet) {
        request.sessionDataTask = [self.manager GET:url parameters:argument progress:^(NSProgress * _Nonnull downloadProgress) {
            [self handleRequestProgress:downloadProgress request:request];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task error:error];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPost){
        if ([request.child respondsToSelector:@selector(constructingBodyBlock)] && [request.child constructingBodyBlock]) {
            request.sessionDataTask = [self.manager POST:url parameters:argument constructingBodyWithBlock:[request.child constructingBodyBlock] progress:^(NSProgress * _Nonnull uploadProgress) {
                [self handleRequestProgress:uploadProgress request:request];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.responseJSONObject = responseObject;
                [self handleRequestSuccess:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailure:task error:error];
            }];
        }
        else{
            request.sessionDataTask = [self.manager POST:url parameters:argument progress:^(NSProgress * _Nonnull uploadProgress) {
                [self handleRequestProgress:uploadProgress request:request];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.responseJSONObject = responseObject;
                [self handleRequestSuccess:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailure:task error:error];
            }];
        }
    }
    else if ([request.child requestMethod] == LCRequestMethodHead){
        request.sessionDataTask = [self.manager HEAD:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task) {
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task error:error];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPut){
       
        request.sessionDataTask = [self.manager PUT:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task error:error];
        }];

    }
    else if ([request.child requestMethod] == LCRequestMethodDelete){
        request.sessionDataTask = [self.manager DELETE:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task error:error];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPatch) {
        request.sessionDataTask = [self.manager PATCH:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task error:error];
        }];
    }
    [self addOperation:request];
}

- (void)handleRequestProgress:(NSProgress *)progress request:(LCBaseRequest *)request{
    if (request.delegate && [request.delegate respondsToSelector:@selector(requestProgress:)]) {
        [request.delegate requestProgress:progress];
    }
    if (request.progressBlock) {
        request.progressBlock(progress);
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask{
    NSString *key = [self keyForRequest:sessionDataTask];
    LCBaseRequest *request = _requestsRecord[key];
    if (request) {
        [request toggleAccessoriesWillStopCallBack];
        
        if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestSuccess:)]) {
            [request.delegate requestSuccess:request];
        }
        if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestFinished:error:)]) {
            [request.delegate requestFinished:request error:nil];
        }
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        if (request.finishedCompletionBlock) {
            request.finishedCompletionBlock(request, nil);
        }
        [request toggleAccessoriesDidStopCallBack];
    }
    
    [self removeOperation:sessionDataTask];
    [request clearCompletionBlock];
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error{
    NSString *key = [self keyForRequest:sessionDataTask];
    LCBaseRequest *request = _requestsRecord[key];
    request.error = error;
    if (request) {
        [request toggleAccessoriesWillStopCallBack];
        if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestFailed:error:)]) {
            [request.delegate requestFailed:request error:error];
        }
        if (request.delegate != nil && [request.delegate respondsToSelector:@selector(requestFinished:error:)]) {
            [request.delegate requestFinished:request error:error];
        }
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request, error);
        }
        if (request.finishedCompletionBlock) {
            request.finishedCompletionBlock(request, error);
        }
        [request toggleAccessoriesDidStopCallBack];
    }
    [self removeOperation:sessionDataTask];
    [request clearCompletionBlock];
}


- (void)cancelRequest:(LCBaseRequest *)request {
    [request.sessionDataTask cancel];
    [self removeOperation:request.sessionDataTask];
    [request clearCompletionBlock];
}


- (void)removeOperation:(NSURLSessionDataTask *)operation {
    NSString *key = [self keyForRequest:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
}


- (void)addOperation:(LCBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self keyForRequest:request.sessionDataTask];
        @synchronized(self) {
            self.requestsRecord[key] = request;
        }
    }
}

- (NSString *)keyForRequest:(NSURLSessionDataTask *)object {
    NSString *key = [@(object.taskIdentifier) stringValue];
    return key;
}

- (void)dealloc{
    [self.manager invalidateSessionCancelingTasks:NO];
}

@end
