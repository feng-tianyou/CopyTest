//
//  People.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "People.h"
#import "Card.h"

@implementation People

- (id)copyWithZone:(NSZone *)zone{
    People *p = [[self class] allocWithZone:zone];
    // 造成死循环
//    p.card = [self.card copy];
    p.card = self.card;
    p.name = self.name;
    return p;
}

@end
