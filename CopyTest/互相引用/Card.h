//
//  Card.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import <Foundation/Foundation.h>

@class People;
@interface Card : NSObject<NSCopying>

@property (nonatomic, copy) NSString *number;
@property (nonatomic, strong) People *people;

@end
