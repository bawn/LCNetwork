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
    return @"todos/1";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}


- (id)responseProcess:(id)responseObject{
    return responseObject[@"title"];
}

// 忽略统一的 Response 加工
- (BOOL)ignoreUnifiedResponseProcess{
    return YES;
}


- (void)dealloc{
    NSLog(@"%s", __func__);
}

@end
