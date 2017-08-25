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
        _hud.mode = MBProgressHUDModeIndeterminate;
//        _hud.label.text = @"正在加载";
//        _hud.label.textColor = [UIColor whiteColor];
//        _hud.square = YES;
//        _hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
//        _hud.bezelView.backgroundColor = [UIColor blackColor];
//        _hud.backgroundView.backgroundColor = [UIColor clearColor];
//        _hud.backgroundColor = [UIColor clearColor];

    }
    return self;
}


- (void)requestWillStart:(id)request {
    [self.hud showAnimated:YES];
}

- (void)requestWillStop:(id)request {
    [self.hud hideAnimated:NO];
}

- (void)requestDidStop:(id)request{
//    [self.hud hide:NO];
}

@end
