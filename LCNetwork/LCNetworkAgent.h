//
//  LCNetworkAgent.h
//  ShellMoney
//
//  Created by beike on 6/4/15.
//  Copyright (c) 2015 beik. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LCBaseRequest;

@interface LCNetworkAgent : NSObject

+ (LCNetworkAgent *)sharedInstance;
- (void)addRequest:(LCBaseRequest *)request;

@end
