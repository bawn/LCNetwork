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
//        _lat = lat;
//        _lng = lng;
        self.requestArgument = @{
                                 @"lat" : lat,
                                 @"lng" : lng
                                 };
    }
    return self;
}


//- (NSDictionary *)requestArgument{
//    return @{
//             @"lat" : _lat,
//             @"lng" : _lng
//             };
//}

- (BOOL)withoutCache{
    return NO;
}

// 接口地址
- (NSString *)apiMethodName{
    
    return @"getweather2.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}


- (NSDictionary *)jsonValidator{
    return @{
             @"City" : [NSString class],
             @"Img" : [NSString class],
             @"Ptime" : [NSString class],
             @"Temp1" : [NSString class],
             @"Temp2" : [NSString class],
             @"Weather" : [NSString class]
             };
}
@end
