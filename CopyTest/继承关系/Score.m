//
//  Score.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Score.h"

@implementation Score

- (id)copyWithZone:(NSZone *)zone{
    Score *s = [[self class] allocWithZone:zone];
    s.math = self.math;
    s.chinese = self.chinese;
    s.english = self.english;
    return s;
}
@end
