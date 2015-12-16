//
//  LCBaseRequest.m
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import "LCBaseRequest.h"
#import "LCNetworkAgent.h"
#import "LCNetworkConfig.h"
#import "TMCache.h"
#import "AFNetworking.h"

@interface LCBaseRequest ()

@property (nonatomic, strong) id cacheJson;
@property (nonatomic, weak) id<LCAPIRequest> child;
@property (nonatomic, strong) NSMutableArray *requestAccessories;
@property (nonatomic, strong) LCNetworkConfig *config;

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
      
    }
    return self;
}

- (void)start{
    [self toggleAccessoriesWillStartCallBack];
    [[LCNetworkAgent sharedInstance] addRequest:self];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(id request))success
                                    failure:(void (^)(id request))failure{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)startWithBlockSuccess:(void (^)(id))success
                      failure:(void (^)(id))failure{
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)startWithBlockProgress:(void (^)(NSProgress *))progress
                  success:(void (^)(id))success
                  failure:(void (^)(id))failure{
    self.progressBlock = progress;
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}


- (id)responseJSONObject{
    id responseJSONObject = nil;
    
    BOOL process = NO;
    // 统一加工response
    if (self.config.processRule && [self.config.processRule respondsToSelector:@selector(processResponseWithRequest:)]) {
        if (([self.child respondsToSelector:@selector(ignoreUnifiedResponseProcess)] && ![self.child ignoreUnifiedResponseProcess]) ||
            ![self.child respondsToSelector:@selector(ignoreUnifiedResponseProcess)]) {
            responseJSONObject = [self.config.processRule processResponseWithRequest:_responseJSONObject];
            process = YES;
        }
    }
    
    if ([self.child respondsToSelector:@selector(responseProcess:)]){
        responseJSONObject = [self.child responseProcess:_responseJSONObject];
        process = YES;
    }
    return process ? responseJSONObject : _responseJSONObject;
}


- (NSInteger)responseStatusCode{
    return [(NSHTTPURLResponse *)self.sessionDataTask.response statusCode];
}

- (id)cacheJson{
    if (_cacheJson) {
        return _cacheJson;
    }
    else{
        NSString *hashKey = [NSString stringWithFormat:@"%lu", (unsigned long)[self.child apiMethodName].hash];
        return [[TMCache sharedCache].diskCache objectForKey:hashKey];
    }
}


- (void)stop {
    [self toggleAccessoriesWillStopCallBack];
    self.delegate = nil;
    [[LCNetworkAgent sharedInstance] cancelRequest:self];
    [self toggleAccessoriesDidStopCallBack];
}


- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
    self.progressBlock = nil;
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

