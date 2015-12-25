//
//  WeatherApi.m
//  LCNetworkDemo
//
//  Created by beike on 6/26/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "Api1.h"

@implementation Api1

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather2.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

// 是否缓存数据
- (BOOL)cacheResponse{
    return YES;
}

- (id)responseProcess:(id)responseObject{
    return responseObject[@"Weather"];
}

// 忽略统一的 Response 加工
- (BOOL)ignoreUnifiedResponseProcess{
    return YES;
}


@end
