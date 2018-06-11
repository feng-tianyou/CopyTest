//
//  Contact.m
//  CopyTest
//
//  Created by FTY on 2018/6/7.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "Contact.h"

@interface Contact()<NSCopying>

@end

@implementation Contact

-(id)copyWithZone:(NSZone *)zone{
    Contact *contact = [[self class] allocWithZone:zone];
    contact.phone = self.phone;
    contact.email = self.email;
    return contact;
}

@end
