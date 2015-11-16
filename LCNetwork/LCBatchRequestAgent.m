//
//  LCBatchRequestAgent.m
//  LCNetwork
//
//  Created by bawn on 7/9/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import "LCBatchRequestAgent.h"

@interface LCBatchRequestAgent ()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation LCBatchRequestAgent


+ (LCBatchRequestAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(LCBatchRequest *)request {
    @synchronized(self) {
        [_requestArray addObject:request];
    }
}

- (void)removeBatchRequest:(LCBatchRequest *)request {
    @synchronized(self) {
        [_requestArray removeObject:request];
    }
}


@end
