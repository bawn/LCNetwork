//
//  LCNetworkAgent.h
//  LCNetwork
//
//  Created by bawn on 6/4/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCBaseRequest;

@interface LCNetworkAgent : NSObject

+ (LCNetworkAgent *)sharedInstance;
- (void)addRequest:(LCBaseRequest *)request;
- (void)cancelRequest:(LCBaseRequest *)request;

@end
