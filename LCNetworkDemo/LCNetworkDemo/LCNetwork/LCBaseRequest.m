//
//  LCBaseRequest.m
//  ShellMoney
//
//  Created by beike on 6/4/15.
//  Copyright (c) 2015 beik. All rights reserved.
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
            NSAssert(NO, @"子类必须要实现APIRequest这个protocol。");
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

- (id)responseJSONObject{
    // 检查是否有统一的response加工
    if (self.config.processRule &&
        [self.config.processRule respondsToSelector:@selector(processResponseWithRequest:)]) {
        return [self.config.processRule processResponseWithRequest:self.requestOperation.responseObject];
    }
    else{
        return self.requestOperation.responseObject;
    }
}


- (NSInteger)responseStatusCode{
    return self.requestOperation.response.statusCode;
}

- (id) cacheJson{
    if (_cacheJson) {
        return _cacheJson;
    }
    else{
        return [[[TMCache sharedCache] diskCache] objectForKey:[self requestHashKey:[self.child apiMethodName]]];
    }
}

- (NSString *)requestHashKey:(NSString *)apiName {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[apiName hash]];
    return key;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
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



