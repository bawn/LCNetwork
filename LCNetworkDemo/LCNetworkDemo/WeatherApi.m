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
    return @"getweather2.aspx";
}


// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

// 是否强制更新缓存
- (BOOL)withoutCache{
    return YES;
}

@end
