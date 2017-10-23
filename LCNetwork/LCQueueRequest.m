//
//  LCQueueRequest.h
//  LCNetwork
//
//  Created by bawn on 7/4/16..
//  Copyright (c) 2016 bawn. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.



#import "LCQueueRequest.h"
#import "LCBaseRequest.h"
#import "LCQueueRequestAgent.h"

static dispatch_group_t queueRequest_request_operation_completion_group() {
    static dispatch_group_t http_request_operation_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http_request_operation_completion_group = dispatch_group_create();
    });
    return http_request_operation_completion_group;
}

@interface LCQueueRequest ()<LCRequestDelegate>

@property (nonatomic, strong) NSMutableArray *requestAccessories;
@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation LCQueueRequest

- (id)init{
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}


- (void)addRequest:(LCBaseRequest *)request{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(queueRequest_request_operation_completion_group(), queue, ^{
        dispatch_group_enter(queueRequest_request_operation_completion_group());
        [[LCQueueRequestAgent sharedInstance] addRequest:self];
        [self.requestArray addObject:request];
        request.delegate = self;
    });
}

- (void)allComplete:(void (^)(void))block{
    [self toggleAccessoriesWillStartCallBack];
    dispatch_group_notify(queueRequest_request_operation_completion_group(), dispatch_get_main_queue(), ^{
        [self toggleAccessoriesWillStopCallBack];
        if (block) {
            block();
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(queueRequestAllComplete:)]) {
            [self.delegate queueRequestAllComplete:self];
        }
        [self toggleAccessoriesDidStopCallBack];
    });
}


#pragma mark - Network Request Delegate

- (void)requestSuccess:(LCBaseRequest *)request {
    dispatch_group_leave(queueRequest_request_operation_completion_group());
    [[LCQueueRequestAgent sharedInstance] removeRequest:self];    
}

- (void)requestFailed:(LCBaseRequest *)request error:(NSError *)error{
    dispatch_group_leave(queueRequest_request_operation_completion_group());
    [[LCQueueRequestAgent sharedInstance] removeRequest:self];
}


#pragma mark - Request Accessoies

- (void)addAccessory:(id<LCRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end


@implementation LCQueueRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack {
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestWillStart:)]) {
                [accessory requestWillStart:self];
            }
        }
    }
}

- (void)toggleAccessoriesWillStopCallBack {
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestWillStop:)]) {
                [accessory requestWillStop:self];
            }
        }
    }
}

- (void)toggleAccessoriesDidStopCallBack {
    if (self.invalidAccessory == NO) {
        for (id<LCRequestAccessory> accessory in self.requestAccessories) {
            if ([accessory respondsToSelector:@selector(requestDidStop:)]) {
                [accessory requestDidStop:self];
            }
        }
    }
}

@end

