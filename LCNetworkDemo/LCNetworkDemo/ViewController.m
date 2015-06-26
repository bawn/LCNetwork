//
//  ViewController.m
//  LCNetworkDemo
//
//  Created by beike on 6/25/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "ViewController.h"
#import "WeatherApi.h"
#import "LCRequestAccessory.h"

@interface ViewController ()<LCRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)buttonPress:(id)sender{
     WeatherApi *api = [[WeatherApi alloc] init];
    
//    if (api.cacheJson) {
//        NSLog(@"%@", api.cacheJson);
//    }
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    
    [api addAccessory:accessory];
    api.requestArgument = @{@"cityName" : @"杭州"};
    [api startWithCompletionBlockWithSuccess:^(WeatherApi *request) {
        //        NSLog(@"%@", request.responseJSONObject);
//        sleep(1);
    } failure:NULL];
    
//    [api start];
//    api.delegate = self;

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
