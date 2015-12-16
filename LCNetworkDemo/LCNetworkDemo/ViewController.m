//
//  ViewController.m
//  LCNetworkDemo
//
//  Created by beike on 6/25/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "ViewController.h"
#import "Api1.h"
#import "Api2.h"
#import "Api3.h"
#import "LCRequestAccessory.h"
#import "LCBatchRequest.h"
#import "HQMultiImageUploadApi.h"

@interface ViewController ()<LCRequestDelegate>

@property (nonatomic, weak) IBOutlet UILabel *city1;
@property (nonatomic, weak) IBOutlet UILabel *city2;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Api1 *api1 = [[Api1 alloc] init];
    
    if (api1.cacheJson) {
//        self.city1.text = api1.cacheJson[@"city"];
    }
    
    Api2 *api2 = [[Api2 alloc] init];
    
    if (api2.cacheJson) {
//        self.city2.text = api2.cacheJson;
    }
}

- (IBAction)api1Press:(id)sender{
    Api1 *api1 = [[Api1 alloc] init];
    api1.requestArgument = @{
                             @"lat" : @"34.12",
                             @"lng" : @"115.21212"
                             };
    
    Api2 *api2 = [[Api2 alloc] init];
    api2.requestArgument = @{
                             @"lat" : @"34.345",
                             @"lng" : @"113.678"
                             };
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    LCBatchRequest *request = [[LCBatchRequest alloc] initWithRequestArray:@[api1, api2]];
    [request addAccessory:accessory];
    
    [request startWithCompletionBlockWithSuccess:^(LCBatchRequest *batchRequest) {
        Api1 *api1 = batchRequest.requestArray.firstObject;
        self.city1.text = api1.responseJSONObject[@"city"];
        Api2 *api2 = batchRequest.requestArray[1];
        self.city2.text = api2.responseJSONObject;// 不需要获取 city 的值，是因为实现了 - (id)responseProcess:(id)responseObject 方法
    } failure:^(LCBatchRequest *batchRequest) {
        
    }];
}

- (IBAction)api2Press:(id)sender{
//    Api2 *api2 = [[Api2 alloc] initWith:@"30.3" lng:@"120.2"];
//    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
//    [api2 addAccessory:accessory];
//    [api2 startWithCompletionBlockWithSuccess:^(Api2 *api2) {
//        if ([api2.responseJSONObject isKindOfClass:[NSError class]]) {
//            // 显示错误信息
//        }
//        else{
//            self.city2.text = api2.responseJSONObject;
//        }
//    } failure:^(id request) {
//        
//    }];
    
    HQMultiImageUploadApi *multiImageUploadApi = [[HQMultiImageUploadApi alloc] init];
    multiImageUploadApi.images = @[[UIImage imageNamed:@"test"], [UIImage imageNamed:@"test1"]];
    [multiImageUploadApi startWithBlockProgress:^(NSProgress *progress) {
        NSLog(@"%f", progress.fractionCompleted);
    } success:^(id request) {
        
    } failure:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LCRequestDelegate Method

- (void)requestFinished:(LCBaseRequest *)request{
    
}

- (void)requestFailed:(LCBaseRequest *)request{
    
}

@end
