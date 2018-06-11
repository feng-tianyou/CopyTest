//
//  BaseModel.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel

- (id)copyWithZone:(NSZone *)zone{
    id object = [[self class] allocWithZone:zone];
    
    unsigned int propertyCount = 0;
    
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        NSObject<NSCopying> *tempValue = [self valueForKey:propertyName];
        if (tempValue) {
            // 此处如果是对象属性，且形成闭环关系，会造成死循环导致崩溃。
            id value = [tempValue copy];
            [object setValue:value forKey:propertyName];
        }
    }
    return object;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int propertyCount = 0;
    
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        NSObject *tempValue = [self valueForKey:propertyName];
        if (tempValue && [tempValue conformsToProtocol:@protocol(NSCopying)]) {
            [aCoder encodeObject:tempValue forKey:propertyName];
        }
        
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        unsigned int propertyCount = 0;
        
        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
        
        for (int i = 0; i < propertyCount; i++) {
            const char *name = property_getName(properties[i]);
            NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            
            NSObject *tempValue = [aDecoder decodeObjectForKey:propertyName];
            if (tempValue) {
                [self setValue:tempValue forKey:propertyName];
            }
        }
    }
    return self;
}


@end
