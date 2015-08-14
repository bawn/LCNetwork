//
//  Money.m
//  LCNetworkDemo
//
//  Created by lingchen on 6/28/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "Api2.h"

@implementation Api2

@synthesize requestArgument;

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather2.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

// 是否缓存数据
- (BOOL)withoutCache{
    return YES;
}

@end
