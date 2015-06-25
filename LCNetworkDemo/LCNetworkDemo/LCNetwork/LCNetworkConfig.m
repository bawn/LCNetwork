//
//  LCNetworkConfig.m
//  ShellMoney
//
//  Created by beike on 6/4/15.
//  Copyright (c) 2015 beik. All rights reserved.
//

#import "LCNetworkConfig.h"

@interface LCNetworkConfig ()


@end

@implementation LCNetworkConfig


+ (LCNetworkConfig *)sharedInstance {
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
        
    }
    return self;
}


@end
