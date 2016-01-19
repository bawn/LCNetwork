//
//  LCNetworkConfig.h
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCBaseRequest;
@class AFSecurityPolicy;

@protocol LCProcessProtocol <NSObject>

@optional
// 加工argument
- (NSDictionary *) processArgumentWithRequest:(NSDictionary *)argument;
// 加工response
- (id) processResponseWithRequest:(id)response;

@end

@interface LCNetworkConfig : NSObject

+ (LCNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *mainBaseUrl;// 主url
@property (nonatomic, strong) NSString *viceBaseUrl;// 副url
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, strong) id <LCProcessProtocol> processRule;

@end
