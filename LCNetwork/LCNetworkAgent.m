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
#import "LCNetworkPrivate.h"
#import "TMCache.h"

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
    }
    return self;
}

- (void)addRequest:(LCBaseRequest <LCAPIRequest>*)request {
    // 配置URL
    NSString *url = [self buildRequestUrl:request];
    // 是否使用 https
    if ([url hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        self.manager.securityPolicy = securityPolicy;
    }
    // 是否使用自定义超时时间
    if ([request.child respondsToSelector:@selector(requestTimeoutInterval)]) {
        self.manager.requestSerializer.timeoutInterval = [request.child requestTimeoutInterval];
    }
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSDictionary *argument = request.requestArgument;
    // 检查是否有统一的参数加工
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processArgumentWithRequest:)]) {
        argument = [self.config.processRule processArgumentWithRequest:request.requestArgument];
    }
    
    if ([request.child respondsToSelector:@selector(requestSerializerType)]) {
        if ([request.child respondsToSelector:@selector(requestSerializerType)] == LCRequestSerializerTypeHTTP) {
            self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        }
        else{
            _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        }
    }
    
    if ([request.child requestMethod] == LCRequestMethodGet) {
        request.sessionDataTask = [self.manager GET:url parameters:argument progress:^(NSProgress * _Nonnull downloadProgress) {
            
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
                if (request.progressBlock) {
                    request.progressBlock(uploadProgress);
                }
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                request.responseJSONObject = responseObject;
                [self handleRequestSuccess:task];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self handleRequestFailure:task];
            }];
        }
        else{
            request.sessionDataTask = [self.manager POST:url parameters:argument progress:^(NSProgress * _Nonnull uploadProgress) {
                if (request.progressBlock) {
                    request.progressBlock(uploadProgress);
                }
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
    if (request.delegate && [request respondsToSelector:@selector(requestProgress:)]) {
        [request.delegate requestProgress:progress];
    }
    if (request.progressBlock) {
        request.progressBlock(progress);
    }
}

- (void)handleRequestSuccess:(NSURLSessionDataTask *)sessionDataTask{
    NSString *key = [self requestHashKey:sessionDataTask];
    LCBaseRequest *request = _requestsRecord[key];
    if (request) {

        
        [request toggleAccessoriesWillStopCallBack];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // 更新缓存
        if (([request.child respondsToSelector:@selector(withoutCache)] && [request.child withoutCache])) {
            [[[TMCache sharedCache] diskCache] setObject:request.responseJSONObject forKey:[self requestHashKey:[request.child apiMethodName]]];
        }
#pragma clang diagnostic pop
        
        // 更新缓存
        if (([request.child respondsToSelector:@selector(cacheResponse)] && [request.child cacheResponse])) {
            [[[TMCache sharedCache] diskCache] setObject:request.responseJSONObject forKey:[self requestHashKey:[request.child apiMethodName]]];
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
    NSString *key = [self requestHashKey:sessionDataTask];
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
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
}


- (void)addOperation:(LCBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self requestHashKey:request.sessionDataTask];
        @synchronized(self) {
            self.requestsRecord[key] = request;
        }
    }
}

- (NSString *)requestHashKey:(id)object {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[object hash]];
    return key;
}

- (NSString *)buildRequestUrl:(LCBaseRequest *)request {
    NSString *baseUrl = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( [request.child respondsToSelector:@selector(isViceUrl)] && [request.child isViceUrl]) {
        baseUrl = self.config.viceBaseUrl;
    }
#pragma clang diagnostic pop
    
    if ([request.child respondsToSelector:@selector(customApiMethodName)]) {
        return [request.child customApiMethodName];
    }
    else{
        if ([request.child respondsToSelector:@selector(useViceUrl)] && [request.child useViceUrl]){
            baseUrl = self.config.viceBaseUrl;
        }
        else{
            baseUrl = self.config.mainBaseUrl;
        }
        if (baseUrl) {
            return [baseUrl stringByAppendingString:[request.child apiMethodName]];
        }
        return [request.child apiMethodName];
    }
}


@end
