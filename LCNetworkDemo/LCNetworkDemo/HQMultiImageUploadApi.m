//
//  HQImageUploadApi.m
//  Mark
//
//  Created by bawn on 12/1/15.
//  Copyright © 2015 huoqiu. All rights reserved.
//

#import "HQMultiImageUploadApi.h"

@implementation HQMultiImageUploadApi

- (NSString *)apiMethodName{
    return @"/image/upload";
}



- (LCRequestMethod)requestMethod{
    return LCRequestMethodPost;
}

- (id)responseProcess:(id)responseObject{
    return responseObject[@"result"][@"images"];
}



- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        for (UIImage *image in self.images) {
            NSData *data = UIImageJPEGRepresentation(image, 1.0);
            NSString *name = @"images";
            NSString *formKey = @"images";
            NSString *type = @"image/jpeg";
            [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
        }
    };
}


@end
