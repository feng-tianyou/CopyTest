//
//  ViewController.m
//  CopyTest
//
//  Created by FTY on 2018/6/6.
//  Copyright © 2018年 FTY. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"
#import "Father.h"
#import "Son.h"
#import "Score.h"

#import "People.h"
#import "Card.h"

#import "FatherModel.h"
#import "ContactModel.h"
#import "CompanyModel.h"

#import "CopyOrStrongModel.h"

@interface ViewController ()


    
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
   
    
}

/// 测试不可变&可变对象进行复制
- (void)immutableTest{
    NSString *immutableStr = @"string";
    NSString *immutableStrCopy = [immutableStr copy];
    NSString *immutableStrMutableCopy = [immutableStr mutableCopy];
    NSLog(@"%@--%p", immutableStr, immutableStr);                       // string--0x100001040
    NSLog(@"%@--%p", immutableStrCopy, immutableStrCopy);               // string--0x100001040
    NSLog(@"%@--%p", immutableStrMutableCopy, immutableStrMutableCopy); // string--0x10075b320

    NSLog(@"------------------------");
    
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:@"string"];
    NSMutableString *mutableStrCopy = [mutableStr copy];
    NSMutableString *mutableStrMutableCopy = [mutableStr mutableCopy];
    NSLog(@"%@--%p", mutableStr, mutableStr);                       // string--0x604000249a50
    NSLog(@"%@--%p", mutableStrCopy, mutableStrCopy);               // string--0xa00676e697274736
    NSLog(@"%@--%p", mutableStrMutableCopy, mutableStrMutableCopy); // string--0x604000249720
    
    NSLog(@"------------------------");
    
    NSArray *immutableArray = @[@"1", @"2"];
    NSArray *immutableArrayCopy = [immutableArray copy];
    NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
    NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x60000003a200
    NSLog(@"%@--%p", immutableArrayCopy, immutableArrayCopy);               // 1,2--0x60000003a200
    NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x600000449de0
    
    NSLog(@"------------------------");
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
    NSMutableArray *mutableArrayCopy = [mutableArray copy];
    NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
    NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
    NSLog(@"%@--%p", mutableArrayCopy, mutableArrayCopy);               // 1,2--0x60000003a340
    NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40
}

/// 测试不可变&可变对象进行复制后的对象类型
- (void)typeForImmutableTest{
    NSString *immutableStr = @"string";
    NSString *immutableStrCopy = [immutableStr copy];
    NSString *immutableStrMutableCopy = [immutableStr mutableCopy];
    NSLog(@"%@--%p", immutableStr, immutableStr);                       // string--0x100001040
    NSLog(@"%@--%p", immutableStrCopy, immutableStrCopy);               // string--0x100001040
    NSLog(@"%@--%p", immutableStrMutableCopy, immutableStrMutableCopy); // string--0x10075b320
    
    [(NSMutableString *)immutableStrMutableCopy appendString:@"追加字符"];
    NSLog(@"%@--%p", immutableStrMutableCopy, immutableStrMutableCopy); // string追加字符--0x10075b320
    
    NSLog(@"------------------------");
    
    NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:@"string"];
    NSMutableString *mutableStrCopy = [mutableStr copy];
    NSMutableString *mutableStrMutableCopy = [mutableStr mutableCopy];
    NSLog(@"%@--%p", mutableStr, mutableStr);                       // string--0x604000249a50
    NSLog(@"%@--%p", mutableStrCopy, mutableStrCopy);               // string--0xa00676e697274736
    NSLog(@"%@--%p", mutableStrMutableCopy, mutableStrMutableCopy); // string--0x604000249720
    
    //    [mutableStrCopy appendString:@"will crash"];
    NSLog(@"------------------------");
    
    NSArray *immutableArray = @[@"1", @"2"];
    NSArray *immutableArrayCopy = [immutableArray copy];
    NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
    NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x60000003a200
    NSLog(@"%@--%p", immutableArrayCopy, immutableArrayCopy);               // 1,2--0x60000003a200
    NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x600000449de0
    
    [(NSMutableArray *)immutableArrayMutableCopy addObject:@"3"];
    NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2,3--0x600000449de0
    NSLog(@"------------------------");
    
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
    NSMutableArray *mutableArrayCopy = [mutableArray copy];
    NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
    NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
    NSLog(@"%@--%p", mutableArrayCopy, mutableArrayCopy);               // 1,2--0x60000003a340
    NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40
    
    // crash
    //    [mutableArrayCopy addObject:@"3"];
}

/// 测试数组完全复制
- (void)arrayDeepCopy{
    NSArray *immutableArray = @[@"1", @"2"];
    NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
    // 归档深复制
    NSArray *archiverDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:immutableArray]];
    // copyItems参数表示：是否里面的元素也进行复制， NO表示浅复制， YES表示深复制
    NSArray *copyItemsDeepCopyArray = [[NSArray alloc] initWithArray:immutableArray copyItems:YES];
    
    NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x604000430900
    NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x604000255300
    NSLog(@"%@--%p", archiverDeepCopyArray, archiverDeepCopyArray); // 1,2--0x604000430840
    NSLog(@"%@--%p", copyItemsDeepCopyArray, copyItemsDeepCopyArray); // 1,2--0x604000430840
    
    NSLog(@"------------------------");
    
    NSLog(@"%@--%p", [immutableArray firstObject], [immutableArray firstObject]);      // 1--0x10d448078
    NSLog(@"%@--%p", [immutableArrayMutableCopy firstObject], [immutableArrayMutableCopy firstObject]); // 1--0x10d448078
    NSLog(@"%@--%p", [archiverDeepCopyArray firstObject], [archiverDeepCopyArray firstObject]); // 1--0xa000000000000311
    NSLog(@"%@--%p", [copyItemsDeepCopyArray firstObject], [copyItemsDeepCopyArray firstObject]); // 1--0xa000000000000311
    
    NSLog(@"------------------------");
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
    NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
    // 归档深复制
    NSArray *archiverDeepCopyArray1 = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mutableArray]];
    NSArray *copyItemsDeepCopyArray1 = [[NSMutableArray alloc] initWithArray:mutableArray copyItems:YES];
    
    NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
    NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40
    NSLog(@"%@--%p", archiverDeepCopyArray1, archiverDeepCopyArray1); // 1,2--0x600000253a10
    NSLog(@"%@--%p", copyItemsDeepCopyArray1, copyItemsDeepCopyArray1); // 1,2--0x60000025c890
    
    NSLog(@"------------------------");
    
    NSLog(@"%@--%p", [mutableArray firstObject], [mutableArray firstObject]);                       // 1--0x10f1f3078
    NSLog(@"%@--%p", [mutableArrayMutableCopy firstObject], [mutableArrayMutableCopy firstObject]); // 1--0x10f1f3078
    NSLog(@"%@--%p", [archiverDeepCopyArray1 firstObject], [archiverDeepCopyArray1 firstObject]); // 1--0xa000000000000311
    NSLog(@"%@--%p", [copyItemsDeepCopyArray1 firstObject], [copyItemsDeepCopyArray1 firstObject]); // 1--0xa000000000000311
}

/// 测试自定义对象进行复制
- (void)customObjectCopyTest{
    Person *person = [[Person alloc] init];
    person.name = @"daisuke";
    person.age = 26;
    
    Person *personCopy = [person copy];
    Person *personMutableCopy = [person mutableCopy];
    
    NSLog(@"%@--%p", person, person.name);                       // <Person: 0x6040000275e0>--0x100349088
    NSLog(@"%@--%p", personCopy, personCopy.name);               // <Person: 0x604000222340>--0x100349088
    NSLog(@"%@--%p", personMutableCopy, personMutableCopy.name); // <Person: 0x604000222b80>--0x100349088
    
    personCopy.name = @"修改name的值";
    NSLog(@"%@-%@-%p", person, person.name, person.name);               // <Person: 0x60000003f140>-daisuke-0x103f1e088
    NSLog(@"%@-%@-%p", personCopy, personCopy.name, personCopy.name);   // <Person: 0x6000002302a0>-修改name的值-0x103f1e0c8
    
    
    
    
    //
    //    NSString *text = @"123";
    //    NSLog(@"%p---", text); // 0x10f36b0c8
    //    NSString *text1 = @"123";
    //    NSLog(@"%p---", text1); // 0x10f36b0c8
    //    NSString *text2 = [[NSString alloc] initWithString:@"123"];
    //    NSLog(@"%p---", text2); // 0x10f36b0c8
    //
    //    NSString *text3 = [NSString stringWithFormat:@"123"];
    //    NSLog(@"%p---", text3); // 0xa000000003332313
    //    NSString *text4 = [[NSString alloc] initWithFormat:@"123"];
    //    NSLog(@"%p---", text4); // 0xa000000003332313
}

/// 测试自定义对象有对象属性进行复制
- (void)customObjectHasObjectCopyTest{
    Person *person = [[Person alloc] init];
    person.name = @"daisuke";
    person.age = 26;
    
    Contact *contact = [[Contact alloc] init];
    contact.phone = @"12345678900";
    contact.email = @"feng@gmail.com";
    person.contact = contact;
    
    //    Person *personCopy = [person copy];
    //    NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
    //    NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
    //    // <Person: 0x600000024a00>--0x10b2a8088--12345678900--0x60000022fdc0
    //    // <Person: 0x600000230300>--0x10b2a8088--12345678900--0x60000022fdc0
    //
    //    personCopy.contact.phone = @"999999999";
    //    personCopy.name = @"这是新的名称";
    //    NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
    //    NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
    //    // <Person: 0x600000024a00>--0x10b2a8088--999999999--0x60000022fdc0
    //    // <Person: 0x600000230300>--0x10b2a8128--999999999--0x60000022fdc0
    
    
    
    Person *personCopy = [person copy];
    NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
    NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
    // <Person: 0x60400042f820>--0x102d04088--12345678900--0x60400042f7c0
    // <Person: 0x60400042f860>--0x102d04088--12345678900--0x60400042f8a0
    
    personCopy.contact.phone = @"999999999";
    personCopy.name = @"这是新的名称";
    NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
    NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
    // <Person: 0x60400042f820>--0x102d04088--12345678900--0x60400042f7c0
    // <Person: 0x60400042f860>--0x102d04128--999999999--0x60400042f8a0
}

/// 测试子类对象有对象属性进行复制
- (void)subClassWithCustomObjectHasObjectCopyTest{
    Son *son = [[Son alloc] init];
    son.height = 173.0;
    son.weight = 120;
    
    Score *score = [[Score alloc] init];
    score.math = 100.0;
    score.chinese = 99.0;
    score.english = 88;
    son.score = score;
    
    Son *sonCopy = [son copy];
    
    //    NSLog(@"%@--%@", son, son.score);                       // <Son: 0x604000266c00>--<Score: 0x60400003e5a0>
    //    NSLog(@"%@--%@", sonCopy, sonCopy.score);               // <Son: 0x604000266d80>--(null)
    
    
    NSLog(@"%@--%@", son, son.score);                       // <Son: 0x6040002760c0>--<Score: 0x604000429e20>
    NSLog(@"%@--%@", sonCopy, sonCopy.score);               // <Son: 0x604000276180>--<Score: 0x604000429e00>
}

/// 让父类的属性也支持深复制
- (void)superCopyWithZoneTest{
    Son *son = [[Son alloc] init];
    son.height = 173.0;
    son.weight = 120;
    
    Score *score = [[Score alloc] init];
    score.math = 100.0;
    score.chinese = 99.0;
    score.english = 88;
    son.score = score;
    
    Contact *contact = [[Contact alloc] init];
    contact.phone = @"123456789";
    contact.email = @"feng@gmail";
    son.contact = contact;
    son.name = @"daisuke";
    
    Son *sonCopy = [son copy];
    
    NSLog(@"%@--%@--%@--%@", son, son.score, son.name, son.contact);                       // <Son: 0x604000273240>--<Score: 0x6040000335e0>--daisuke--<Contact: 0x604000033600>
    NSLog(@"%@--%@--%@--%@", sonCopy, sonCopy.score, sonCopy.name, sonCopy.contact);               // <Son: 0x600000460700>--<Score: 0x6000000301c0>--daisuke--<Contact: 0x6000000301a0>
}

/// 闭环方式
- (void)refreToEachOtherTest{
    Card *card = [[Card alloc] init];
    card.number = @"9999999";
    
    People *people = [[People alloc] init];
    people.name = @"daisuke";
    
    card.people = people;
    people.card = card;
    
    Card *cardCopy = [card copy];
    NSLog(@"%@--%@--%@", card, card.people, card.people.card);
    NSLog(@"%@--%@--%@", cardCopy, cardCopy.people, cardCopy.people.card);
    // <Card: 0x60000042b700>--<People: 0x6000004297e0>--<Card: 0x60000042b700>
    // <Card: 0x60000042b640>--<People: 0x60000042bac0>--<Card: 0x60000042b700>
}

/// runtime方式深复制
- (void)runtimeCopyingTest{
    FatherModel *father = [[FatherModel alloc] init];
    father.name = @"daisuke";
    father.age = 26;
    
    ContactModel *contact = [[ContactModel alloc] init];
    contact.phone = @"123456789";
    contact.email = @"feng@gmail";
    father.contact = contact;
    
    FatherModel *fatherCopy = [father copy];
    NSLog(@"%@--%@--%@--%@", father, father.name, father.contact.phone, father.contact);
    NSLog(@"%@--%@--%@--%@", fatherCopy, fatherCopy.name,fatherCopy.contact.phone, fatherCopy.contact);
    // <FatherModel: 0x604000035b80>--daisuke--123456789--<ContactCodingModel: 0x604000035ba0>
    // <FatherModel: 0x604000231960>--daisuke--123456789--<ContactCodingModel: 0x6040002312e0>
}

/// runtime方式归档深复制
- (void)runtimeCodingTest{
    FatherModel *father = [[FatherModel alloc] init];
    father.name = @"daisuke";
    father.age = 26;
    
    CompanyModel *company = [[CompanyModel alloc] init];
    company.companyName = @"小公司";
    father.company = company;
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:father];
    FatherModel *fatherCopy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"%@--%@--%@--%@", father, father.name, father.company, father.company.companyName);
    NSLog(@"%@--%@--%@--%@", fatherCopy, fatherCopy.name,fatherCopy.company, fatherCopy.company.companyName);
    // <FatherModel: 0x60400024fbd0>--daisuke--<CompanyCodingModel: 0x6040000086b0>--小公司
    // <FatherModel: 0x60400024fba0>--daisuke--(null)--(null)
    
    
    // <FatherModel: 0x60400025a550>--daisuke--<CompanyCodingModel: 0x604000012240>--小公司
    // <FatherModel: 0x600000257d30>--daisuke--<CompanyCodingModel: 0x6000000076f0>--小公司
}


- (void)copyOrStrongNSStringTest{
    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];
    
    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    
    model.name = stringM;
    
    // copy
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x6040002556c0
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke追加--0x6040002556
    
    // strong
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x6040002556c0
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke追加--0x60000025d460--daisuke追加--0x60000025d46
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // 1
}


- (void)overrideSetNameTest{
    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];
    
    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    model.name = stringM;
    
    // copy
    //    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    //    // daisuke--0xa656b75736961647--daisuke--0x6040000564d0
    //    [stringM appendString:@"追加"];
    //    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    //    // daisuke--0xa656b75736961647--daisuke追加--0x6040000564d0
    //    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // 0
    
    // strong
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x604000445880
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke追加--0x604000445880
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // 0
}

- (void)copyOrStrongNSMutableStringTest{
    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];
    
    NSMutableString *string = @"daisuke".mutableCopy;
    model.mutableString1 = string;
    model.mutableString2 = string;
    
    NSLog(@"strong声明的model.mutableString1的类型是否是NSMutableString： %@", @([model.mutableString1 isKindOfClass:[NSMutableString class]]));
    // strong声明的model.mutableString1的类型是否是NSMutableString： 1
    NSLog(@"copy声明的model.mutableString1的类型是否是NSMutableString： %@", @([model.mutableString2 isKindOfClass:[NSMutableString class]]));
    // copy声明的model.mutableString1的类型是否是NSMutableString： 0
}

@end
