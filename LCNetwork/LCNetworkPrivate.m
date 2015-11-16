//
//  LCNetworkPrivate.m
//  LCNetworkDemo
//
//  Created by bawn on 9/2/15.
//  Copyright (c) 2015 bawn. All rights reserved.
//

#import "LCNetworkPrivate.h"

@implementation LCNetworkPrivate

+ (void)checkJson:(id)json key:(NSString *)key withValidator:(id)validatorJson{
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
                [self checkJson:value key:key withValidator:format];
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    NSAssert2(NO, @"JSON类型错误>>>>> %@:%@", key, format);
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
                [self checkJson:item key:key withValidator:validator];
            }
        }
    }
    else if ([json isKindOfClass:validatorJson]) {
        return;
    }
    else {
        NSAssert2(NO, @"JSON类型错误>>>>> %@:%@", key, [self classFromObjct:json]);
    }
}


+ (void)checkJson:(id)json withValidator:(id)validatorJson {
    [self checkJson:json key:nil withValidator:validatorJson];
}

+ (Class)classFromObjct:(id)object{
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [NSDictionary class];
    }
    else if ([object isKindOfClass:[NSArray class]]) {
        return [NSArray class];
    }
    else if ([object isKindOfClass:[NSString class]]) {
        return [NSString class];
    }
    else if ([object isKindOfClass:[NSNumber class]]) {
        return [NSNumber class];
    }
    else{
        return nil;
    }
}


@end
