//
//  FatherModel.h
//  CopyTest
//
//  Created by FTY on 2018/6/8.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "BaseModel.h"
#import "ContactModel.h"
#import "CompanyModel.h"

@interface FatherModel : BaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
/// 联系方式
@property (nonatomic, strong) ContactModel *contact;
/// 公司
@property (nonatomic, strong) CompanyModel *company;

@end
