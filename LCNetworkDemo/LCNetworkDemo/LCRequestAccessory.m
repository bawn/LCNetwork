//
//  LCRequestAccessory.m
//  ShellMoney
//
//  Created by beike on 6/9/15.
//  Copyright (c) 2015 beik. All rights reserved.
//

#import "LCRequestAccessory.h"
#import <MBProgressHUD.h>

@interface LCRequestAccessory ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation LCRequestAccessory


- (instancetype) initWithShowVC:(UIViewController *)vc{
    self = [super init];
    if (self) {
        _hud = [[MBProgressHUD alloc] initWithView:vc.view];
        [vc.view addSubview:_hud];
        _hud.mode = MBProgressHUDModeText;
        _hud.labelText = @"正在加载";
        _hud.square = YES;
    }
    return self;
}


- (void)requestWillStart:(id)request {
    [self.hud show:YES];
}

- (void)requestWillStop:(id)request {
    
}

- (void)requestDidStop:(id)request{
    [self.hud hide:NO];
}

@end
