//
//  WeatherApi.m
//  LCNetworkDemo
//
//  Created by beike on 6/26/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "WeatherApi.h"

@implementation WeatherApi

@synthesize requestArgument;

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

// 每次请求完缓存数据
- (BOOL)withoutCache{
    return YES;
}

- (NSString *)requestTime{
    return @"16:00";
}

@end
