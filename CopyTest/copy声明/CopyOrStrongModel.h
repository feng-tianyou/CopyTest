//
//  CopyOrStrongModel.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CopyOrStrongModel : NSObject

//@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSMutableString *mutableString1;
@property (nonatomic, copy) NSMutableString *mutableString2;



@end
