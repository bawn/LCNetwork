//
//  LCBatchRequestAgent.h
//  LCNetworkDemo
//
//  Created by beike on 7/9/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LCBatchRequest;

@interface LCBatchRequestAgent : NSObject

+ (LCBatchRequestAgent *)sharedInstance;

- (void)addBatchRequest:(LCBatchRequest *)request;

- (void)removeBatchRequest:(LCBatchRequest *)request;


@end
