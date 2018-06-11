//
//  People.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Card;
@interface People : NSObject<NSCopying>

@property (nonatomic, weak) Card *card;
@property (nonatomic, copy) NSString *name;
@end
