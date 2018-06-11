//
//  ContactModel.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "BaseModel.h"

@interface ContactModel : BaseModel

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;


@end
