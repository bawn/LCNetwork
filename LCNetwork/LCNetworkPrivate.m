//
//  LCNetworkPrivate.m
//  LCNetworkDemo
//
//  Created by bawn on 9/2/15.
//  Copyright (c) 2015 beike. All rights reserved.
//

#import "LCNetworkPrivate.h"

@implementation LCNetworkPrivate

+ (void)checkJson:(id)json withValidator:(id)validatorJson {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [validatorJson isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = validatorJson;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                [self checkJson:value withValidator:format];
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    NSAssert1(NO, @"JSON类型错误----%@----", key);
                }
            }
        }
    } else if ([json isKindOfClass:[NSArray class]] &&
               [validatorJson isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)validatorJson;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = validatorJson[0];
            for (id item in array) {
                [self checkJson:item withValidator:validator];
            }
        }
    }else {
        NSAssert(NO, @"response数据错误");
    }
}


@end
