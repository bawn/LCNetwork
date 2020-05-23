//
//  Money.m
//  LCNetworkDemo
//
//  Created by lingchen on 6/28/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "Api2.h"

@interface Api2 ()

@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;


@end

@implementation Api2


// 接口地址
- (NSString *)apiMethodName {
    return @"posts";
}

- (id)responseProcess:(id)responseObject {
    if ([responseObject isKindOfClass:NSArray.class]) {
        return [[responseObject firstObject] valueForKey:@"title"];
    }
    return responseObject[@"title"];
}

// 忽略统一的 Response 加工
- (BOOL)ignoreUnifiedResponseProcess {
    return YES;
}


// 请求方式
- (LCRequestMethod)requestMethod {
    return LCRequestMethodGet;
}

- (void)dealloc{
    NSLog(@"%s", __func__);
}


@end
