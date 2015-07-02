//
//  WeatherApi.m
//  LCNetworkDemo
//
//  Created by beike on 6/26/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "Api1.h"

@implementation Api1
// 参数属性
@synthesize requestArgument;

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather.aspx";
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
