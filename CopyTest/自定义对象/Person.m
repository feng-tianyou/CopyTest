//
//  Person.m
//  CopyTest
//
//  Created by FTY on 2018/6/7.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Person.h"

@interface Person()<NSCopying, NSMutableCopying>


@end

@implementation Person

- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    p.name = self.name;
    p.age = self.age;
//    p.contact = self.contact;
    // 深复制
    p.contact = [self.contact copy];
    return p;
}

//- (id)copyWithZone:(NSZone *)zone{
//    //创建新的对象空间
//    Person *p = [[self class] allocWithZone:zone];
//    p.name = [NSString stringWithFormat:@"%@", self.name];
//    p.age = self.age;
//    return p;
//}


//- (id)copyWithZone:(NSZone *)zone{
//    // 返回对象本身
//    return self;
//}

- (id)mutableCopyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    
    //为每个属性创建新的空间，并将内容复制
    p.name = self.name;
    p.age = self.age;
    return p;
}
@end
