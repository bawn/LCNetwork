//
//  LCNetworkAgent.m
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import "LCNetworkAgent.h"
#import "LCNetworkConfig.h"
#import "LCBaseRequest.h"
#import "AFNetworking.h"
#import "TMCache.h"
#import "LCBaseRequest+Internal.h"

@interface LCNetworkAgent ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestsRecord;
@property (nonatomic, strong) LCNetworkConfig *config;

@end

@implementation LCNetworkAgent


+ (LCNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _config = [LCNetworkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (void)addRequest:(LCBaseRequest <LCAPIRequest>*)request {

    NSString *url = request.urlString;
    // 是否使用自定义超时时间
    if ([request.child respondsToSelector:@selector(requestTimeoutInterval)]) {
        self.manager.requestSerializer.timeoutInterval = [request.child requestTimeoutInterval];
    }
    
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", @"text/plain", nil];
    serializer.removesKeysWithNullValues = YES;
    if ([request.child respondsToSelector:@selector(removesKeysWithNullValues)]) {
        serializer.removesKeysWithNullValues = [request.child removesKeysWithNullValues];
    }
    self.manager.responseSerializer = serializer;

    NSDictionary *argument = request.requestArgument;
    // 检查是否有统一的参数加工
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processArgumentWithRequest:)]) {
        argument = [self.config.processRule processArgumentWithRequest:request.requestArgument];
    }
    
    if ([request.child respondsToSelector:@selector(requestSerializerType)]) {
        if ([request.child requestSerializerType] == LCRequestSerializerTypeHTTP) {
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        else{
            self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
    }
    
    if ([request.child requestMethod] == LCRequestMethodGet) {
        request.sessionDataTask = [self.manager GET:url parameters:argument progress:^(NSProgress * _Nonnull downloadProgress) {
            [self handleRequestProgress:downloadProgress request:request];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPost){
        // multipart `POST` request
        if ([request.child respondsToSelector:@selector(constructingBodyBlock)] && [request.child constructingBodyBlock]) {
            
            request.sessionDataTask = [self.manager POST:url parameters:argument constructingBodyWithBlock:[request.child constructingBodyBlock] progress:^(NSProgress * _Nonnull uploadProgress) {
                [self handleRequestProgress:uploadProgress request:request];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.responseJSONObject = responseObject;
                [self handleRequestSuccess:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailure:task];
            }];
        }
        else{
            request.sessionDataTask = [self.manager POST:url parameters:argument progress:^(NSProgress * _Nonnull uploadProgress) {
                [self handleRequestProgress:uploadProgress request:request];
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.responseJSONObject = responseObject;
                [self handleRequestSuccess:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailure:task];
            }];
        }
    }
    else if ([request.child requestMethod] == LCRequestMethodHead){
        request.sessionDataTask = [self.manager HEAD:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task) {
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPut){
       
        request.sessionDataTask = [self.manager PUT:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task];
        }];

    }
    else if ([request.child requestMethod] == LCRequestMethodDelete){
        request.sessionDataTask = [self.manager DELETE:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPatch) {
        request.sessionDataTask = [self.manager PATCH:url parameters:argument success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            request.responseJSONObject = responseObject;
            [self handleRequestSuccess:task];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestFailure:task];
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
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 更新缓存
        if (([request.child respondsToSelector:@selector(withoutCache)] && [request.child withoutCache])) {
            [[[TMCache sharedCache] diskCache] setObject:request.responseJSONObject forKey:request.urlString];
        }
#pragma clang diagnostic pop
        
        // 更新缓存
        if (([request.child respondsToSelector:@selector(cacheResponse)] && [request.child cacheResponse])) {
            [[[TMCache sharedCache] diskCache] setObject:request.responseJSONObject forKey:request.urlString];
        }
        
        if (request.delegate != nil) {
            [request.delegate requestFinished:request];
        }
        if (request.successCompletionBlock) {
            request.successCompletionBlock(request);
        }
        [request toggleAccessoriesDidStopCallBack];
   
    }
    
    [self removeOperation:sessionDataTask];
    [request clearCompletionBlock];
}

- (void)handleRequestFailure:(NSURLSessionDataTask *)sessionDataTask{
    NSString *key = [self keyForRequest:sessionDataTask];
    LCBaseRequest *request = _requestsRecord[key];
    if (request) {
        [request toggleAccessoriesWillStopCallBack];
        if (request.delegate != nil) {
            [request.delegate requestFinished:request];
        }
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request);
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

@end
