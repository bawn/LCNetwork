//
//  LCNetworkConfig.h
//  ShellMoney
//
//  Created by beike on 6/4/15.
//  Copyright (c) 2015 beik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCBaseRequest;

@protocol LCProcessProtocol <NSObject>

@optional
// 加工参数
- (NSDictionary *) processArgumentWithRequest:(LCBaseRequest *)request;
// 加工response
- (id) processResponseWithRequest:(id)response;

@end

@interface LCNetworkConfig : NSObject

+ (LCNetworkConfig *)sharedInstance;

@property (nonatomic, strong) NSString *mainBaseUrl;// 主url
@property (nonatomic, strong) NSString *viceBaseUrl;// 副url
@property (nonatomic, assign) BOOL logEnabled; // 是否启用打印
@property (nonatomic, strong) id <LCProcessProtocol> processRule;
@end
