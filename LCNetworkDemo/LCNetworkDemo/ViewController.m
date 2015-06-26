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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    LCRequestAccessory *accessory = [[LCRequestAccessory alloc] initWithShowVC:self];
    WeatherApi *api = [[WeatherApi alloc] init];
//    [api addAccessory:accessory];
    api.requestArgument = @{
                            @"lat" : @"34.345",
                            @"lng" : @"113.678"
                            };
    [api startWithCompletionBlockWithSuccess:^(WeatherApi *request) {
//        NSLog(@"%@", request.responseJSONObject);
    } failure:NULL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
