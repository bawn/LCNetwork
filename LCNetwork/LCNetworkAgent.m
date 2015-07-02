//
//  LCNetworkAgent.m
//  ShellMoney
//
//  Created by beike on 6/4/15.
//  Copyright (c) 2015 beik. All rights reserved.
//

#import "LCNetworkAgent.h"
#import "LCNetworkConfig.h"
#import "LCBaseRequest.h"
#import "AFNetworking.h"
#import "TMCache.h"
#import <NSDate+DateTools.h>

@interface LCNetworkAgent ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
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
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _requestsRecord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRequest:(LCBaseRequest <LCAPIRequest>*)request {
    // 配置URL
    NSString *url = [self buildRequestUrl:request];
    // 是否使用https
    if ([url hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [[AFSecurityPolicy alloc] init];
        [securityPolicy setAllowInvalidCertificates:YES];
        self.manager.securityPolicy = securityPolicy;
    }
    // 是否使用自定义超时时间
    if ([request.child respondsToSelector:@selector(requestTimeoutInterval)]) {
        self.manager.requestSerializer.timeoutInterval = [request.child requestTimeoutInterval];
    }
    // 是否自定义请求时间
    if ([self processRequestTime:request]) {
        return;
    }
    self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    NSDictionary *argument = [request.child requestArgument];
    // 检查是否有统一的参数加工
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processArgumentWithRequest:)]) {
        argument = [self.config.processRule processArgumentWithRequest:request.child];
    }
   
    if ([request.child requestMethod] == LCRequestMethodGet) {
        request.requestOperation = [self.manager GET:url parameters:argument success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPost){
        
        if ([request.child respondsToSelector:@selector(constructingBodyBlock)] && [request.child constructingBodyBlock]) {
            request.requestOperation = [self.manager POST:url parameters:argument constructingBodyWithBlock:[request.child constructingBodyBlock] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        }
        else{
            request.requestOperation = [self.manager POST:url parameters:argument success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleRequestResult:operation];
            }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleRequestResult:operation];
            }];
        }
    }
    else if ([request.child requestMethod] == LCRequestMethodPost){
       
        
    }
    else if ([request.child requestMethod] == LCRequestMethodHead){
        request.requestOperation = [self.manager HEAD:url parameters:argument success:^(AFHTTPRequestOperation *operation) {
            [self handleRequestResult:operation];
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPut){
        request.requestOperation = [_manager PUT:url parameters:argument success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodDelete){
        request.requestOperation = [_manager DELETE:url parameters:argument success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
    }
    else if ([request.child requestMethod] == LCRequestMethodPatch) {
        request.requestOperation = [_manager PATCH:url parameters:argument success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
    }
    [self addOperation:request];
}

- (void)handleRequestResult:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    LCBaseRequest *request = _requestsRecord[key];
    if (request) {
        BOOL success = [self checkResult:request];
        if (success) {
            [request toggleAccessoriesWillStopCallBack];
            [self printfRequestInfo:request];
            // 强制更新缓存
            if (([request.child respondsToSelector:@selector(withoutCache)] && [request.child withoutCache])
                || [request.child respondsToSelector:@selector(requestTime)]) {
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
        else{
            [request toggleAccessoriesWillStopCallBack];
            [self printfRequestInfo:request];
            if ([request.child respondsToSelector:@selector(requestTime)]) {
                
                NSString *hashString = [[request.child apiMethodName] stringByAppendingFormat:@"%ld", (long)[request.child requestMethod]];
                NSString *hashKey = [self requestHashKey:hashString];
                [[TMCache sharedCache].diskCache removeObjectForKey:hashKey];
                
            }
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
        
    }
    [self removeOperation:operation];
    [request clearCompletionBlock];
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
}

- (BOOL)checkResult:(LCBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    return result;
}


- (void)addOperation:(LCBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
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
    NSString *baseUrl;
    if ( [request.child respondsToSelector:@selector(isViceUrl)] && [request.child isViceUrl]) {
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

- (BOOL)processRequestTime:(LCBaseRequest *)request{
    if ([request.child respondsToSelector:@selector(requestTime)]) {
        NSString *timeString = [request.child requestTime];
        NSString *hashString = [[request.child apiMethodName] stringByAppendingFormat:@"%ld", (long)[request.child requestMethod]];
        NSString *hashKey = [self requestHashKey:hashString];
        NSDate *limitDate = [NSDate dateWithString:timeString formatString:@"HH:mm"];
        NSDate *localDate = [NSDate date];
        id lastDate = [[[TMCache sharedCache] diskCache] objectForKey:hashKey];
        if (lastDate) {
            NSDate *newData = [NSDate dateWithYear:[lastDate year] month:[lastDate month] day:[lastDate day] hour:limitDate.hour minute:limitDate.minute second:limitDate.second];
            NSInteger days = [localDate daysLaterThan:newData];
            if (days) {
                [[[TMCache sharedCache] diskCache] setObject:localDate forKey:hashKey];
            }
            else{
                [request toggleAccessoriesDidStopCallBack];
                return YES;
            }
        }
        else{
            [[[TMCache sharedCache] diskCache] setObject:localDate forKey:hashKey];
        }
    }
    return NO;
}

- (void)printfRequestInfo:(LCBaseRequest *)request{
    if (self.config.logEnabled){
        NSLog(@"URL:---------%@", request.requestOperation.request.URL);
        if (request.requestOperation.error) {
            NSLog(@"%@", request.requestOperation.error);
        }
        else{
            NSLog(@"%@", request.responseJSONObject);
        }
    }
}

@end
