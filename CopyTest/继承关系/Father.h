//
//  Father.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contact.h"

@interface Father : NSObject<NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
/// 联系方式
@property (nonatomic, strong) Contact *contact;

@end
