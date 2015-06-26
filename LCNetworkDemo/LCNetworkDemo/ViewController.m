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
    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    WeatherApi *api = [[WeatherApi alloc] init];
    [api addAccessory:accessory];
    api.requestArgument = @{
                            @"lat" : @"34.345",
                            @"lng" : @"113.678"
                            };
    [api startWithCompletionBlockWithSuccess:^(WeatherApi *request) {
        //        NSLog(@"%@", request.responseJSONObject);
        sleep(1);
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
