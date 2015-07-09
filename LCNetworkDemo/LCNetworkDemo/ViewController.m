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

@interface ViewController ()<LCRequestDelegate>

@property (nonatomic, weak) IBOutlet UILabel *weather1;
@property (nonatomic, weak) IBOutlet UILabel *weather2;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    Api1 *api1 = [[Api1 alloc] init];
    
    if (api1.cacheJson) {
        self.weather1.text = api1.cacheJson[@"Weather"];
    }
    
    Api2 *api2 = [[Api2 alloc] init];
    
    if (api2.cacheJson) {
        self.weather2.text = api2.cacheJson[@"Weather"];
    }
    
    
}

- (IBAction)api1Press:(id)sender{
    Api1 *api1 = [[Api1 alloc] init];
//    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
//    
//    [api1 addAccessory:accessory];
    api1.requestArgument = @{@"cityName" : @"杭州"};
//    [api1 startWithCompletionBlockWithSuccess:^(Api1 *api1) {
//        self.weather1.text = api1.responseJSONObject[@"Weather"];
//    } failure:^(id request) {
//        
//    }];
    
    Api2 *api2 = [[Api2 alloc] init];
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
//    [api2 addAccessory:accessory];
    api2.requestArgument = @{
                             @"lat" : @"34.345",
                             @"lng" : @"113.678"
                             };
//    [api2 startWithCompletionBlockWithSuccess:^(Api2 *api2) {
//        self.weather2.text = api2.responseJSONObject[@"Weather"];
//    } failure:NULL];

    
    
    LCBatchRequest *request = [[LCBatchRequest alloc] initWithRequestArray:@[api1, api2]];
    [request addAccessory:accessory];
    [request startWithCompletionBlockWithSuccess:^(LCBatchRequest *batchRequest) {
        Api1 *api1 = batchRequest.requestArray.firstObject;
//        NSLog(@"%@", api1.responseJSONObject);
        self.weather1.text = api1.responseJSONObject[@"Weather"];
        Api2 *api2 = batchRequest.requestArray[1];
//        NSLog(@"%@", api2.responseJSONObject);
        self.weather2.text = api2.responseJSONObject[@"Weather"];
    } failure:^(LCBatchRequest *batchRequest) {
        
    }];
    
//    [api start];
//    api.delegate = self;

}

- (IBAction)api2Press:(id)sender{
    Api2 *api2 = [[Api2 alloc] init];
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    [api2 addAccessory:accessory];
    api2.requestArgument = @{
                             @"lat" : @"34.345",
                             @"lng" : @"113.678"
                             };
    [api2 startWithCompletionBlockWithSuccess:^(Api2 *api2) {
        self.weather2.text = api2.responseJSONObject[@"Weather"];
    } failure:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestFinished:(LCBaseRequest *)request{
    
}

- (void)requestFailed:(LCBaseRequest *)request{
    
}

@end
