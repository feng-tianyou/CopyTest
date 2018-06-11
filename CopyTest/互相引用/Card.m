//
//  Card.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Card.h"
#import "People.h"

@implementation Card

- (id)copyWithZone:(NSZone *)zone{
    Card *card = [[self class] allocWithZone:zone];
    card.people = [self.people copy];
    // 重新指向新创建的card
    card.people.card = card;
    card.number = self.number;
    return card;
}

@end
