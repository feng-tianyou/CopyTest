//
//  CopyOrStrongModel.m
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "CopyOrStrongModel.h"

@implementation CopyOrStrongModel

- (void)setName:(NSString *)name{
    NSLog(@"%p", name);
    _name = [name copy];
    NSLog(@"%p", _name);
}

@end
