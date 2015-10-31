//
//  Api3.m
//  LCNetworkDemo
//
//  Created by beike on 7/2/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "Api3.h"

@implementation Api3

// 接口地址
- (NSString *)apiMethodName{
    return @"getweather2.aspx";
}

// 请求方式
- (LCRequestMethod)requestMethod{
    return LCRequestMethodPost;
}


// 是否有上传数据
- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation([UIImage imageNamed:@"currentPageDot"], 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

@end
