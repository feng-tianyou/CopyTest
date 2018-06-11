
//  Father.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Father.h"

@implementation Father

- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Father *f = [[self class] allocWithZone:zone];
    f.name = self.name;
    f.age = self.age;
    // 深复制
    f.contact = [self.contact copy];
    return f;
}

@end
