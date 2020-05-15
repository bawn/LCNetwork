//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "LCProcessFilter.h"
#import "LCBaseRequest.h"

@implementation LCProcessFilter

- (NSDictionary *)processArgumentWithRequest:(NSDictionary *)argument query:(NSDictionary *)queryArgument{
    return argument;
}

//- (id)processResponseWithRequest:(id)response{
//    return response[@"city"];
//}

//- (id) processResponseWithRequest:(id)response{
//    if ([response[@"result"] isEqualToString:@"error"]) {
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: response[@"message"]};
//        return [NSError errorWithDomain:ErrorDomain code:0 userInfo:userInfo];
//    }
//    else{
//        return response[@"data"];
//    }
//}


- (NSDictionary *)requestHeaderValue{
    return @{@"X-UUID" : @"1"};
}

- (BOOL)isSuccess:(id)response{
    return response[@"city"];
}

- (NSArray *)authorizationHeaderFieldArray{
    return @[@"10002312", @""];
}

- (NSString *)errorMessage:(id)response{
    return response[@"city"];
}

@end
