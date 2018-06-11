//
//  Son.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Father.h"
#import "Score.h"

@interface Son : Father

@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
/// 成绩
@property (nonatomic, strong) Score *score;
@end
