//
//  Son.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Son.h"

@implementation Son

- (id)copyWithZone:(NSZone *)zone{
    Son *s = [super copyWithZone:zone];
    s.height = self.height;
    s.weight = self.weight;
    s.score = [self.score copy];
    return s;
}

@end
