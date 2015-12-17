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



- (BOOL)cacheResponse{
    return YES;
}

// 接口地址
- (NSString *)apiMethodName{
    
    return @"geo2loc_2.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodGet;
}

//- (id)responseProcess:(id)responseObject{
//    return responseObject[@"city"];
//}

//- (BOOL)ignoreUnifiedResponseProcess{
//    return YES;
//}

@end
