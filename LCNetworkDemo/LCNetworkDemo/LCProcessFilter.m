//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "LCProcessFilter.h"
#import "LCBaseRequest.h"

@implementation LCProcessFilter

- (NSDictionary *)processArgumentWithRequest:(NSDictionary *)argument{
    return argument;
}

- (id) processResponseWithRequest:(id)response{
    return response;
}

@end
