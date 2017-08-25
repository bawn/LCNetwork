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
#import "LCChainRequest.h"
#import <AFNetworking.h>
#import "HQMultiImageUploadApi.h"
#import <AFURLResponseSerialization.h>

#import "LCNetworkAgent.h"

@interface ViewController ()<LCRequestDelegate, LCChainRequestDelegate>

@property (nonatomic, weak) IBOutlet UILabel *city1;
@property (nonatomic, weak) IBOutlet UILabel *city2;
@property (nonatomic, weak) IBOutlet UILabel *city3;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)firstAction:(id)sender{
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

    [request startWithBlockSuccess:^(LCBatchRequest *batchRequest) {
        Api1 *api1 = batchRequest.requestArray.firstObject;
        self.city1.text = api1.responseJSONObject;// 不需要获取 Weather 的值，是因为实现了 - (id)responseProcess:(id)responseObject 方法
        Api2 *api2 = batchRequest.requestArray[1];
        self.city1.text = api2.responseJSONObject;
    } failure:^(LCBatchRequest *batchRequest, NSError *error) {
        
    }];
    
    // api1返回的结构是：
    /*
     {
     "City": "商丘",
     "Weather": "晴",
     "Temp1": "6℃",
     "Temp2": "-8℃",
     "Ptime": "14:20",
     "Img": "http://api.zdoz.net/api/weatherIcon/晴日.png"
     }
     */

}

- (IBAction)secondPress:(id)sender{
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
    
    LCChainRequest *chainRequest = [[LCChainRequest alloc] init];
    [chainRequest addAccessory:accessory];
    
    [chainRequest addRequest:api1 callback:^(LCChainRequest *chainRequest, __kindof LCBaseRequest *request) {
        NSLog(@"%@", request.responseJSONObject);
        self.city2.text = api1.responseJSONObject;
        [chainRequest addRequest:api2 callback:^(LCChainRequest *chainRequest, __kindof LCBaseRequest *request) {
            NSLog(@"%@", request.responseJSONObject);
            self.city2.text = api2.responseJSONObject;
        }];
    }];
    [chainRequest start];
}

- (IBAction)thirdPress:(id)sender{
    
    
    Api2 *api2 = [[Api2 alloc] initWith:@"30.3" lng:@"120.2"];
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    [api2 addAccessory:accessory];
    [api2 startWithBlockSuccess:^(Api2 *api2) {
        self.city3.text = api2.responseJSONObject;// 不需要获取 city 的值，是因为设置了统一的 response 处理，查看 LCProcessFilter
        NSLog(@"%d", api2.isSuccess);
    } failure:^(__kindof LCBaseRequest *request, NSError *error) {
        
    }];
    
    // api2返回的结构是：
    /*
     {
     "city": "杭州市",
     "country": "中国",
     "direction": "",
     "distance": "",
     "district": "江干区",
     "province": "浙江省",
     "street": "亭苑街",
     "street_number": "",
     "country_code": 0
     }
     */
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - LCRequestDelegate Method

- (void)requestFinished:(LCBaseRequest *)request{
    
}

- (void)requestFailed:(LCBaseRequest *)request error:(NSError *)error{
    
}

- (void)requestProgress:(NSProgress *)progress{
    NSLog(@"%f", progress.fractionCompleted);
}

- (void)chainRequestFinished:(LCChainRequest *)chainRequest {
    // all requests are done
}

- (void)chainRequestFailed:(LCChainRequest *)chainRequest failedBaseRequest:(LCBaseRequest*)request {
    // some one of request is failed
}

@end
