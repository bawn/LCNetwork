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


- (instancetype)initWith:(NSString *)lat lng:(NSString *)lng{
    self = [super init];
    if (self) {
//        self.requestArgument = @{
//                                 @"lat" : lat,
//                                 @"lng" : lng
//                                 };
    }
    return self;
}

// 接口地址
- (NSString *)apiMethodName{
    return @"todos/1";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

- (void)dealloc{
    NSLog(@"%s", __func__);
}


@end
