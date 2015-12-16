//
//  HQMultiImageUploadApi.h
//  Mark
//
//  Created by bawn on 12/1/15.
//  Copyright © 2015 huoqiu. All rights reserved.
//
//  多图上传
//  http://gitlab.xinpinget.com/root/Saturn/wikis/image_upload#%E5%9B%BE%E7%89%87%E4%B8%8A%E4%BC%A0
#import "LCBaseRequest.h"

@interface HQMultiImageUploadApi : LCBaseRequest<LCAPIRequest>

@property (nonatomic, strong) NSArray *images;

@end
