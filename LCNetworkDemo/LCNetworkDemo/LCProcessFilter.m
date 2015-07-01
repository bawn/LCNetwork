//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "LCProcessFilter.h"
#import "LCBaseRequest.h"

@implementation LCProcessFilter

- (NSDictionary *)processArgumentWithRequest:(LCBaseRequest <LCAPIRequest> *)request{
    return request.requestArgument;
}

- (id) processResponseWithRequest:(id)response{
    return response;
}

@end
