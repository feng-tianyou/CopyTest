[浅析iOS的浅复制与深复制](https://www.cnblogs.com/loying/p/4862275)

最近同事问我一个问题：原数组A，进行复制得到数组B，改变数组B的Person元素对象，不影响数组A的Person元素对象，如何操作？
第一感觉是进行深复制，同样数组里面的元素对象也要进行深复制，于是就找到相关的API：

```ObjC
- (instancetype)initWithArray:(NSArray<ObjectType> *)array copyItems:(BOOL)flag;
```
然后同事跟我说还有其他方法吗？要不分享一下iOS的复制吧？然后就有了这篇文章。文章如有错误欢迎指出更正，小弟虚心受教，也怕误人子弟。


### 为什么要复制？

定义：在面向对象编程中，对象复制是创建一个现有对象的副本，即面向对象编程中的一个数据单元。生成的对象称为对象副本或者仅仅是原始对象的副本。

意义：为了操作对象副本数据时不影响原对象数据

### 在iOS中哪些类支持复制功能？

NSString、NSMutableString、NSArray、NSMutableArray、NSDictionary、NSMutableDictionary…
不难发现在API中这些类需要遵循`<NSCopying, NSMutableCopying>`。至于为什么要遵循这两个协议，协议中需要实现哪些方法后面涉及，这里不做阐释。但是至少可以总结出想要类支持复制功能，就要遵循`<NSCopying, NSMutableCopying>`以及实现对应方法。

### 浅复制 or 深复制？

复制主要分为浅复制和深复制。

- 浅复制：拷贝指向对象的指针，而不是对象本身。
- 深复制：拷贝对象内容指向另外一块内存。

下图是浅复制与深复制的关系（下图来自官方文档）
![image](http://7xv233.com1.z0.glb.clouddn.com/copy1.png)

举个例子：

```ObjC
NSString *immutableStr = @"不可变字符串";
NSString *immutableStrCopy = [immutableStr copy];
NSString *immutableStrMutableCopy = [immutableStr mutableCopy];
NSLog(@"%@--%p", immutableStr, immutableStr);                       // name--0x100001040
NSLog(@"%@--%p", immutableStrCopy, immutableStrCopy);               // name--0x100001040
NSLog(@"%@--%p", immutableStrMutableCopy, immutableStrMutableCopy); // name--0x10075b320

NSLog(@"------------------------");

NSMutableString *mutableStr = [[NSMutableString alloc] initWithString:@"可变字符串"];
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
```


**总结：**
- 不可变对象：进行copy得到的是浅复制，进行mutableCopy得到的是深复制。
- 可变对象：无论进行copy还是mutableCopy都是深复制。


类型 | copy | mutableCopy
---|---|---
NSString | 浅复制 | 深复制
NSMutableString | 深复制 | 深复制
NSArray | 浅复制 | 深复制
NSMutableArray | 深复制 | 深复制
... | ... | ...



### 声明类型一定是进行复制后的类型吗？

![image](http://7xv233.com1.z0.glb.clouddn.com/copy2.png)

断点调试发现不是，比如：immutableStrMutableCopy声明的是不可变类型NSString，NSString类型是不可以对字符串进行增删操作的，然而NSMutableString类型却可以。因为iOS是动态语言，运行时才断定是什么类型，显然immutableStrMutableCopy实际是NSMutableString，可以对它进行追加字符串，例如：

```ObjC
[(NSMutableString *)immutableStrMutableCopy appendString:@"追加字符"];
NSLog(@"%@--%p", immutableStrMutableCopy, immutableStrMutableCopy); // string追加字符--0x10075b320
```

相反mutableStrCopy声明的是NSMutableString类型，实际是NSString类型，如果对mutableStrCopy进行增删操作，必然crash。


```ObjC
[mutableStrCopy appendString:@"will crash"];
```

> Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[NSTaggedPointerString appendString:]: unrecognized selector sent to instance 0xa00676e697274736'
mutableStrCopy对象没有appendString:这个方法。

以此类推，同样对于数组来说：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy3.png)

显然根据断点信息：
immutableArrayMutableCopy是NSMutableArray，可以添加新对象
```ObjC
[(NSMutableArray *)immutableArrayMutableCopy addObject:@"3"];
NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2,3--0x600000449de0
```

mutableArrayCopy是NSArray，添加新的对象会crash

```ObjC
// crash
[mutableArrayCopy addObject:@"3"];
```

> Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSArrayI addObject:]: unrecognized selector sent to instance 0x600000430600'

**总结：**
- 不可变对象进行mutableCopy得到的是可变对象.
- 可变对象进行copy得到的是不可变对象。

### 深复制真的是深复制吗？


```ObjC
NSArray *immutableArray = @[@"1", @"2"];
NSArray *immutableArrayCopy = [immutableArray copy];
NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x60000003a200
NSLog(@"%@--%p", immutableArrayCopy, immutableArrayCopy);               // 1,2--0x60000003a200
NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x600000449de0

NSLog(@"------------------------");

NSLog(@"%@--%p", [immutableArray firstObject], [immutableArray firstObject]);      // 1--0x10d448078
NSLog(@"%@--%p", [immutableArrayCopy firstObject], [immutableArrayCopy firstObject]);  // 1--0x10d448078
NSLog(@"%@--%p", [immutableArrayMutableCopy firstObject], [immutableArrayMutableCopy firstObject]); // 1--0x10d448078
NSLog(@"------------------------");

NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
NSMutableArray *mutableArrayCopy = [mutableArray copy];
NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
NSLog(@"%@--%p", mutableArrayCopy, mutableArrayCopy);               // 1,2--0x60000003a340
NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40

NSLog(@"------------------------");

NSLog(@"%@--%p", [mutableArray firstObject], [mutableArray firstObject]);                       // 1--0x10f1f3078
NSLog(@"%@--%p", [mutableArrayCopy firstObject], [mutableArrayCopy firstObject]);               // 1--0x10f1f3078
NSLog(@"%@--%p", [mutableArrayMutableCopy firstObject], [mutableArrayMutableCopy firstObject]); // 1--0x10f1f3078
```


从上面的代码筛选出`深复制`的例子：


```ObjC
NSArray *immutableArray = @[@"1", @"2"];
NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x60000003a200
NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x600000449de0

NSLog(@"------------------------");

NSLog(@"%@--%p", [immutableArray firstObject], [immutableArray firstObject]);      // 1--0x10d448078
NSLog(@"%@--%p", [immutableArrayMutableCopy firstObject], [immutableArrayMutableCopy firstObject]); // 1--0x10d448078
NSLog(@"------------------------");

NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40

NSLog(@"------------------------");

NSLog(@"%@--%p", [mutableArray firstObject], [mutableArray firstObject]);                       // 1--0x10f1f3078
NSLog(@"%@--%p", [mutableArrayMutableCopy firstObject], [mutableArrayMutableCopy firstObject]); // 1--0x10f1f3078
```

发现深复制只作用于数组对象这层，而数组对象里面存放的元素并没有复制。引用[官方文档](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Collections/Articles/Copying.html#//apple_ref/doc/uid/TP40010162-SW3)里面的一句话：
> “This kind of copy is only capable of producing a one-level-deep copy. If you only need a one-level-deep copy...
If you need a true deep copy, such as when you have an array of arrays…”
理解为这只是单层深复制(one-level-deep copy)

那么现在区分一下概念：
- 浅复制(shallow copy)：在浅复制操作时，对于被复制对象指针复制。
- 深复制(one-level-deep copy)：在深复制操作时，对于被复制对象，至少有一层是深复制。
- 完全复制(real-deep copy)：在完全复制操作时，对于被复制对象的每一层都是对象复制。

![image](http://7xv233.com1.z0.glb.clouddn.com/copy4.png)

根据上图（来自官网）举例例子场景说明：
- 单层深复制：数组A，进行深复制得到数组B，当修改数组B里面的对象时，数组A里面的对象也会跟着变。
- 完全复制：数组A，进行深复制得到数组B，当修改数组B里面的对象时，数组A里面的对象不会跟着变。

那么对于集合怎样才算是完全复制呢？

#### 归档方式

```ObjC
NSArray *immutableArray = @[@"1", @"2"];
NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
// 归档深复制
NSArray *archiverDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:immutableArray]];

NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x604000430900
NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x604000255300
NSLog(@"%@--%p", archiverDeepCopyArray, archiverDeepCopyArray); // 1,2--0x604000430840

NSLog(@"------------------------");

NSLog(@"%@--%p", [immutableArray firstObject], [immutableArray firstObject]);      // 1--0x10d448078
NSLog(@"%@--%p", [immutableArrayMutableCopy firstObject], [immutableArrayMutableCopy firstObject]); // 1--0x10d448078
NSLog(@"%@--%p", [archiverDeepCopyArray firstObject], [archiverDeepCopyArray firstObject]); // 1--0xa000000000000311
NSLog(@"------------------------");

NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
// 归档深复制
NSArray *archiverDeepCopyArray1 = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:mutableArray]];


NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40
NSLog(@"%@--%p", archiverDeepCopyArray1, archiverDeepCopyArray1); // 1,2--0x600000253a10

NSLog(@"------------------------");

NSLog(@"%@--%p", [mutableArray firstObject], [mutableArray firstObject]);                       // 1--0x10f1f3078
NSLog(@"%@--%p", [mutableArrayMutableCopy firstObject], [mutableArrayMutableCopy firstObject]); // 1--0x10f1f3078
NSLog(@"%@--%p", [archiverDeepCopyArray1 firstObject], [archiverDeepCopyArray1 firstObject]); // 1--0xa000000000000311
```


通过上述例子使用归档方式可以达到完全复制。


#### 自带API初始化方式

```ObjC
NSArray *immutableArray = @[@"1", @"2"];
NSArray *immutableArrayMutableCopy = [immutableArray mutableCopy];
// 深复制
// copyItems参数表示：是否里面的元素也进行复制， NO表示浅复制， YES表示深复制
NSArray *copyItemsDeepCopyArray = [[NSArray alloc] initWithArray:immutableArray copyItems:YES];
NSArray *copyItemsDeepCopyArray2 = [[NSMutableArray alloc] initWithArray:immutableArray copyItems:YES];

NSLog(@"%@--%p", immutableArray, immutableArray);                       // 1,2--0x604000430900
NSLog(@"%@--%p", immutableArrayMutableCopy, immutableArrayMutableCopy); // 1,2--0x604000255300
NSLog(@"%@--%p", copyItemsDeepCopyArray, copyItemsDeepCopyArray); // 1,2--0x604000430840

NSLog(@"------------------------");

NSLog(@"%@--%p", [immutableArray firstObject], [immutableArray firstObject]);      // 1--0x10d448078
NSLog(@"%@--%p", [immutableArrayMutableCopy firstObject], [immutableArrayMutableCopy firstObject]); // 1--0x10d448078
NSLog(@"%@--%p", [copyItemsDeepCopyArray firstObject], [copyItemsDeepCopyArray firstObject]); // 1--0xa000000000000311

NSLog(@"------------------------");

NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:@[@"1", @"2"]];
NSMutableArray *mutableArrayMutableCopy = [mutableArray mutableCopy];
// 深复制
NSArray *copyItemsDeepCopyArray1 = [[NSMutableArray alloc] initWithArray:mutableArray copyItems:YES];

NSLog(@"%@--%p", mutableArray, mutableArray);                       // 1,2--0x60000005c9e0
NSLog(@"%@--%p", mutableArrayMutableCopy, mutableArrayMutableCopy); // 1,2--0x60000005ca40
NSLog(@"%@--%p", copyItemsDeepCopyArray1, copyItemsDeepCopyArray1); // 1,2--0x60000025c890

NSLog(@"------------------------");

NSLog(@"%@--%p", [mutableArray firstObject], [mutableArray firstObject]);                       // 1--0x10f1f3078
NSLog(@"%@--%p", [mutableArrayMutableCopy firstObject], [mutableArrayMutableCopy firstObject]); // 1--0x10f1f3078
NSLog(@"%@--%p", [copyItemsDeepCopyArray1 firstObject], [copyItemsDeepCopyArray1 firstObject]); // 1--0xa000000000000311
```

使用上述两种方式均可达到完全复制的效果。

**有四个注意点：**

1. 使用归档方式：归档的对象必须遵循NSCoding协议并实现协议方法。
2. 使用归档方式：使用NSKeyedArchiver归档的对象是什么类型，那么NSKeyedUnarchiver解档出来的对象就是什么类型
比如归档的是NSArray类型，解档得到的类型也是NSArray：
NSArray *archiverDeepCopyArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:immutableArray]];
3. 使用实例化方法：如果copyItems为YES，那么数组的元素对象必须遵循NSCopying协议并实现协议方法，否则crash
4. 使用实例化方法：使用什么类型进行初始化的，得到的就是什么类型的对象。
比如使用NSMutableArray进行初始化，那么copyItemsDeepCopyArray1就是NSMutableArray类型，而不是NSArray类型：
NSArray *copyItemsDeepCopyArray1 = [[NSMutableArray alloc] initWithArray:mutableArray copyItems:YES];


### 如何让对象支持复制操作？

上面提及到只要遵循`<NSCopying, NSMutableCopying>`以及实现协议方法就可以实现复制操作，那先看看这两个协议有什么协议方法：


```ObjC
@protocol NSCopying

- (id)copyWithZone:(nullable NSZone *)zone;

@end

@protocol NSMutableCopying

- (id)mutableCopyWithZone:(nullable NSZone *)zone;

@end
```

自定义Person类实现浅复制&深复制

```ObjC
// Person.h
@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;

@end


// Person.m
// 深复制
- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    p.name = self.name;
    p.age = self.age;
    return p;
}

// 浅复制（伪复制）
//- (id)copyWithZone:(NSZone *)zone{
//    // 返回对象本身
//    return self;
//}

// 深复制
- (id)mutableCopyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];

    //为每个属性创建新的空间，并将内容复制
    p.name = self.name;
    p.age = self.age;
    return p;
}
```

测试：

```ObjC
Person *person = [[Person alloc] init];
person.name = @"daisuke";
person.age = 26;

Person *personCopy = [person copy];
Person *personMutableCopy = [person mutableCopy];

NSLog(@"%@--%p", person, person.name);                       // <Person: 0x6040000275e0>--0x100349088
NSLog(@"%@--%p", personCopy, personCopy.name);               // <Person: 0x604000222340>--0x100349088
NSLog(@"%@--%p", personMutableCopy, personMutableCopy.name); // <Person: 0x604000222b80>--0x100349088
```


从打印结果的出都实现了深复制操作。但是一般来说自定义对象不需要实现NSMutableCopying协议，因为对象不像容器，本身没有相关存储扩展等功能。

看到这里可能细心的人发现都是深复制，为什么person对象里面的name属性地址没有深复制？

由于NSString特殊性，系统会判断字符串属性在同一内容前提下，使用@“”或者initWith..方法创建的对象作为常量，放在常量区则不会开辟新的内存空间。

验证：

```ObjC
NSString *text = @"123";
NSLog(@"%p---", text); // 0x10f36b0c8
NSString *text1 = @"123";
NSLog(@"%p---", text1); // 0x10f36b0c8
NSString *text2 = [[NSString alloc] initWithString:@"123"];
NSLog(@"%p---", text2); // 0x10f36b0c8
```

发现不同变量，因为内容一致，指向的地址是一样的。所以除了改变值，难道就没有开辟新内存空间的方法了吗？有

NSString *text3 = [NSString stringWithFormat:@"123"];
NSLog(@"%p---", text3); // 0xa000000003332313
NSString *text4 = [[NSString alloc] initWithFormat:@"123"];
NSLog(@"%p---", text4); // 0xa000000003332313

会发现同样的内容，但是地址是不一样的，而且长度也不一样。

**总结：**
- @“”或者initWith..方法的变量存放在常量区，由系统管理内存
- Format:方式创建的变量存放在堆区

所以想要实现完全的复制可以这样做：

```ObjC
// Person.m
- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    p.name = [NSString stringWithFormat:@"%@", self.name];
    p.age = self.age;
    return p;
}
```

实现完全复制无非就是怕修改副本对象的属性，从而影响到原对象的属性。对于字符串来说，其实你可以不需要这样做。因为副本对象修改字符串属性不会影响原对象的字符串属性。

验证：

```ObjC

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

```

上面的代码中看到尽管两个对象name的地址是一样的，但是修改对象personCopy的属性name的值，并没有影响到对象person的name值。


### 对象中有对象属性时如何支持复制操作？

新建一个Contact类作为person的一个属性：

```ObjC
// Person.h
@interface Person : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
/// 联系方式
@property (nonatomic, strong) Contact *contact;

@end
```

在copyWithZone:方法中

```ObjC
// Person.m
- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    p.name = self.name;
    p.age = self.age;
    p.contact = self.contact;
    return p;
}

```

测试：
```ObjC
Person *person = [[Person alloc] init];
person.name = @"daisuke";
person.age = 26;

Contact *contact = [[Contact alloc] init];
contact.phone = @"12345678900";
contact.email = @"feng@gmail.com";
person.contact = contact;

Person *personCopy = [person copy];
NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
// <Person: 0x600000024a00>--0x10
b2a8088--12345678900--0x60000022fdc0
// <Person: 0x600000230300>--0x10b2a8088--12345678900--0x60000022fdc0

personCopy.contact.phone = @"999999999";
personCopy.name = @"这是新的名称";
NSLog(@"%@--%p--%@--%p", person, person.name, person.contact.phone, person.contact);
NSLog(@"%@--%p--%@--%p", personCopy, personCopy.name,personCopy.contact.phone, personCopy.contact);
// <Person: 0x600000024a00>--0x10b2a8088--999999999--0x60000022fdc0
// <Person: 0x600000230300>--0x10b2a8128--999999999--0x60000022fdc0
```

从打印信息看到person是进行了深复制，但是对象contact指向的是同一个指针，显然并没有进行深复制(单层深复制)，也可以从copyWithZone:方法中看到p.contact = self.contact;只是简单的指针赋值。如果改变副本personCopy的contact对象属性，原对象的contact也会跟着改变，这不是我们想要的结果。那应该怎么办呢？方法是让属性对象也实现深复制功能

例如Contact也实现深复制：

```ObjC
// Contact.m
-(id)copyWithZone:(NSZone *)zone{
    Contact *contact = [[self class] allocWithZone:zone];
    contact.phone = self.phone;
    contact.email = self.email;
    return contact;
}
```

Contact类继承NSCopying协议实现了深复制功能，然后在Person类的深复制方法中修改为：

```ObjC
// Person.m
- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Person *p = [[self class] allocWithZone:zone];
    p.name = self.name;
    p.age = self.age;
    //    p.contact = self.contact;
    // 深复制
    p.contact = [self.contact copy];
    return p;
}
```

这样就能让对象属性实现深复制效果,验证：

```ObjC
Person *person = [[Person alloc] init];
person.name = @"daisuke";
person.age = 26;

Contact *contact = [[Contact alloc] init];
contact.phone = @"12345678900";
contact.email = @"feng@gmail.com";
person.contact = contact;

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
```


从打印信息可以看到，person与personCopy指针不一样，person的contact对象属性与personCopy的contact对象属性指针不一样。
而且当修改personCopy的contact对象属性中的phone值时，原对象person的contact对象属性中的phone值没有跟着改变，所以是实现了完全复制。

### 如何让子类对象支持复制操作？

为了不影响Person类，新建一个Father类：

```ObjC
// Father.h
@interface Father : NSObject<NSCopying>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
/// 联系方式
@property (nonatomic, strong) Contact *contact;

@end

// Father.m
@implementation Father

- (id)copyWithZone:(NSZone *)zone{
    //创建新的对象空间
    Father *f = [[self class] allocWithZone:zone];
    f.name = self.name;
    f.age = self.age;
    // 深复制
    f.contact = [self.contact copy];
    return f;
}

@end
```

Father类稍微做了调整，把继承NSCopying协议放在.h文件中,再新建一个Son类继承Father类：

```ObjC
// Son.h
@interface Son : Father

@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
/// 成绩
@property (nonatomic, strong) Score *score;
@end
```

因为是继承关系，子类也遵循了NSCopying协议，但是并没有重写copyWithZone:方法，如果进行复制操作会是怎样的结果呢？


```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    Son *son = [[Son alloc] init];
    son.height = 173.0;
    son.weight = 120;

    Score *score = [[Score alloc] init];
    score.math = 100.0;
    score.chinese = 99.0;
    score.english = 88;
    son.score = score;

    Son *sonCopy = [son copy];

    NSLog(@"%@--%@", son, son.score);                       // <Son: 0x604000266c00>--<Score: 0x60400003e5a0>
    NSLog(@"%@--%@", sonCopy, sonCopy.score);               // <Son: 0x604000266d80>--(null)

}
```


打印信息显示，son对象进行了深复制，但是sonCopy的score对象是空的。为什么呢？因为进行[son copy]操作时，子类没有重写copyWithZone:方法，会去父类那里找，也可以从断点中看到：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy5.png)

父类中self指向的是Son类，那么[[self class] allocWithZone:zone]表示给son创建一个新的空间，也就是之前打印信息显示结果一样完成了深复制操作，但是f对象中没有给score对象属性赋值，所以是null的。

想要score有值，必然要重写copyWithZone:方法。

```ObjC
// Son.m
@implementation Son

- (id)copyWithZone:(NSZone *)zone{
    Son *s = [[self class] allocWithZone:zone];
    s.height = self.height;
    s.weight = self.height;
    s.score = [self.score copy];
    return s;
}

@end
```

而且Score也要实现深复制操作：

```ObjC
// Score.m
@implementation Score

- (id)copyWithZone:(NSZone *)zone{
    Score *s = [[self class] allocWithZone:zone];
    s.math = self.math;
    s.chinese = self.chinese;
    s.english = self.english;
    return s;
}
@end
```
接下来验证一下：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    Son *son = [[Son alloc] init];
    son.height = 173.0;
    son.weight = 120;

    Score *score = [[Score alloc] init];
    score.math = 100.0;
    score.chinese = 99.0;
    score.english = 88;
    son.score = score;

    Son *sonCopy = [son copy];

    NSLog(@"%@--%@", son, son.score);                       // <Son: 0x6040002760c0>--<Score: 0x604000429e20>
    NSLog(@"%@--%@", sonCopy, sonCopy.score);      // <Son: 0x604000276180>--<Score: 0x604000429e00>

}
```

通过打印信息看到实现深复制功能。

但是可能有一个疑问？Son是继承Father类的，要是Father类的属性也有值呢？
首先不修改复制方法的代码，简单的给Father类的属性赋值测试一下先：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

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

    NSLog(@"%@--%@--%@--%@", son, son.score, son.name, son.contact);                       
    // <Son: 0x604000273240>--<Score: 0x6040000335e0>--daisuke--<Contact: 0x604000033600>
    NSLog(@"%@--%@--%@--%@", sonCopy, sonCopy.score, sonCopy.name, sonCopy.contact);               
    // <Son: 0x604000273580>--<Score: 0x604000236c00>--(null)--(null)

}
```

从打印信息看到sonCopy.name和sonCopy.contact两个值都是null的，为什么呢？
因为Son类重写了copyWithZone:方法，自己完成了深复制操作，并没有考虑到父类也需要深复制。自然而然没有运行父类的copyWithZone:方法，所以就出现了sonCopy对象的父类属性值时null的。
修改如下：

```ObjC
// Son.m
- (id)copyWithZone:(NSZone *)zone{
    // 使用super
    Son *s = [super copyWithZone:zone];
    s.height = self.height;
    s.weight = self.height;
    s.score = [self.score copy];
    return s;
}
```


测试：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

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

    NSLog(@"%@--%@--%@--%@", son, son.score, son.name, son.contact);                      
    // <Son: 0x604000273240>--<Score: 0x6040000335e0>--daisuke--<Contact: 0x604000033600>
    NSLog(@"%@--%@--%@--%@", sonCopy, sonCopy.score, sonCopy.name, sonCopy.contact);               
    // <Son: 0x600000460700>--<Score: 0x6000000301c0>--daisuke--<Contact: 0x6000000301a0>

}
```


这样sonCopy.name和 sonCopy.contact两个属性都有值了，也完成了深复制，从断点也可以看到运行了父类的copyWithZone:方法，并且把父类的相关属性进行了深复制，如下图显示：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy6.png)


### 互相引用进行深拷贝结果如何？

在很多多情况下，对象都是互相引用的，当然一个是strong一个是weak，否则造成循环引用，引起内存泄漏。比如：信用卡必须有一个人的属性，而人未必有信用卡的属性。那么对信用卡进行深复制，结果是如何呢？
第一反应想到的是首先创建一个People类并拥有一个（weak引用）card属性，一个Card类并拥有一个（strong引用）people属性。然后遵循NSCopying协议，实现copyWithZone:方法。
结果发现在People类中的copyWithZone:方法中不能对card进行copy操作，因为进行copy的时候新对象的引用计数器会+1，这样跟weak引用造成冲突：

```ObjC
// People.m
@implementation People

- (id)copyWithZone:(NSZone *)zone{
People *p = [[self class] allocWithZone:zone];
    // 警告：Assigning retained object to weak property; object will be released after assignment
    p.card = [self.card copy];
    return p;
}

@end
```

> 警告信息：Assigning retained object to weak property; object will be released after assignment

因为card属性是weak类型，不能对它进行copy操作。否则造成死循环而崩溃，如下图显示：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy7.png)

那么不能进行copy操作，直接赋值会怎样呢？


```ObjC
// Card.h
@class People;
@interface Card : NSObject<NSCopying>

@property (nonatomic, copy) NSString *number;
@property (nonatomic, strong) People *people;

@end

// Card.m
@implementation Card

- (id)copyWithZone:(NSZone *)zone{
    Card *card = [[self class] allocWithZone:zone];
    card.people = [self.people copy];
    card.number = self.number;
    return card;
}

@end

// People.h
@class Card;
@interface People : NSObject<NSCopying>

@property (nonatomic, weak) Card *card;
@property (nonatomic, copy) NSString *name;
@end

// People.m
@implementation People

- (id)copyWithZone:(NSZone *)zone{
    People *p = [[self class] allocWithZone:zone];
    p.card = self.card;
    p.name = self.name;
    return p;
}

@end
```


测试：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

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
```


从打印信息看出card.people.card、cardCopy.people.card两个的地址是一样的：0x60000042b700，而0x60000042b700指向的是card的地址，通过一张图展示他们的关系：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy8.png)

显然这个不是我们想要的结果，想要的结果如下图显示：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy9.png)

因为对对象进行深复制，里面的对象属性也要深复制，但是因为对象属性是weak引用，不允许copy操作，否则造死成循环而崩溃，怎么办呢？
由于能力有限，只能做一下简单处理，如果哪位有好的建议请联系我，谢谢。

```ObjC
// Card.m
@implementation Card

- (id)copyWithZone:(NSZone *)zone{
    Card *card = [[self class] allocWithZone:zone];
    card.people = [self.people copy];
    // 重新指向新创建的card
    card.people.card = card;
    card.number = self.number;
    return card;
}

@end
```

把people的card属性重新指向新创建的card，进行测试：


```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    Card *card = [[Card alloc] init];
    card.number = @"9999999";

    People *people = [[People alloc] init];
    people.name = @"daisuke";

    card.people = people;
    people.card = card;

    Card *cardCopy = [card copy];
    NSLog(@"%@--%@--%@", card, card.people, card.people.card);
    NSLog(@"%@--%@--%@", cardCopy, cardCopy.people, cardCopy.people.card);
    // <Card: 0x60400003a9e0>--<People: 0x60400042d120>--<Card: 0x60400003a9e0>
    // <Card: 0x60400042c220>--<People: 0x60400042b560>--<Card: 0x60400042c220>
}
```

显然这样就能简单实现想要的结果。

### 基类runtime方式让所有子类自动实现深复制操作（有不足之处）

创建基类BaseModel，有两种方式实现深复制：

#### 基类BaseModel遵循NSCopying协议

```ObjC
// BaseModel.m
- (id)copyWithZone:(NSZone *)zone{
    id object = [[self class] allocWithZone:zone];

    unsigned int propertyCount = 0;

    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    for (int i = 0; i < propertyCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];

        NSObject<NSCopying> *tempValue = [self valueForKey:propertyName];
        if (tempValue) {
            // 此处如果是对象属性，且形成闭环关系，会造成死循环导致崩溃。
            id value = [tempValue copy];
            [object setValue:value forKey:propertyName];
        }
    }
    return object;
}
```


使用runtime方式遍历递归对象的属性而进行深复制，这里有一个弊端，该方式不适合有闭环方式的对象使用，否则造成死循环。上面讲的互相引用的例子就是这个的证明，关系如下图显示：

![image](http://7xv233.com1.z0.glb.clouddn.com/copy10.png)

所以使用BaseModel类方式的话，必须确保对象与对象之间没有形成闭环关闭。那么就测试一下没有闭环关系例子：

新建FatherModel类、ContactModel类分别继承于BaseModel类

```ObjC
// FatherModel.h
@interface FatherModel : BaseModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
/// 联系方式
@property (nonatomic, strong) ContactModel *contact;

@end

// FatherModel.m
@implementation FatherModel

@end

// ContactModel.h
@interface ContactModel : BaseModel

@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;

@end

// ContactModel.m
@implementation ContactModel

@end
```

测试：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

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
    // <FatherModel: 0x604000035b80>--daisuke--123456789--<ContactModel: 0x604000035ba0>
    // <FatherModel: 0x604000231960>--daisuke--123456789--<ContactModel: 0x6040002312e0>
}
```

从打印信息中看到实现了深复制功能。

> 注意点：对象属性如果没有遵循NSCopying协议，只是简单赋值，不会进行深复制操作。

#### 基类BaseModel遵循NSCoding协议

```ObjC
// BaseModel.m
@implementation BaseModel

- (void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int propertyCount = 0;

    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

    for (int i = 0; i < propertyCount; i++) {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];

        NSObject *tempValue = [self valueForKey:propertyName];
        if (tempValue && [tempValue conformsToProtocol:@protocol(NSCopying)]) {
            [aCoder encodeObject:tempValue forKey:propertyName];
        }
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        unsigned int propertyCount = 0;

        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

        for (int i = 0; i < propertyCount; i++) {
            const char *name = property_getName(properties[i]);
            NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];

            NSObject *tempValue = [aDecoder decodeObjectForKey:propertyName];
            if (tempValue) {
                [self setValue:tempValue forKey:propertyName];
            }
        }
    }
    return self;
}

@end
```

测试新建CompanyModel类没有继承BaseModel，也没有遵循NSCoding协议。

```ObjC
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
// <FatherModel: 0x60400024fbd0>--daisuke--<CompanyModel: 0x6040000086b0>--小公司
// <FatherModel: 0x60400024fba0>--daisuke--(null)--(null)
```


从打印信息看到fatherCopy的company是空的。那么让CompanyModel类继承BaseModel，然后直接运行：


```ObjC
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

// <FatherModel: 0x60400025a550>--daisuke--<CompanyModel: 0x604000012240>--小公司
// <FatherModel: 0x600000257d30>--daisuke--<CompanyModel: 0x6000000076f0>--小公司
```

发现属性有值了且完成了深复制操作。

### 声明属性是使用copy、strong的区别？

新建一个CopyOrStrongModel类。

#### copy声明

```ObjC
// 使用copy声明name属性：
@interface CopyOrStrongModel : NSObject

@property (nonatomic, copy) NSString *name;

@end
```

测试：

```
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];
    model.name = @"daisuke";
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // model.name是否是NSMutableString类型：0

}
```

把值改为是可变类型的：


```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];

    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    model.name = stringM;

    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x6040002556c0
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke追加--0x6040002556
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // model.name是否是NSMutableString类型：0
}
```

发现虽然stringM是可变字符串，但是进行model.name = stringM;实际是对可变字符串进行了[可变字符串 copy]操作，从而得到的是NSString类型。

#### strong声明

```ObjC
@property (nonatomic, strong) NSString *name;
```

测试：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];
    model.name = @"daisuke";
    NSLog(@"%@--%p", model.name, model.name);

}
```

使用这种方式跟copy一样，但是使用可变字符串赋值又会如何呢？


```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];

    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    model.name = stringM;

    // strong
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x6040002556c0
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke追加--0x60000025d460--daisuke追加--0x60000025d46
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // model.name是否是NSMutableString类型：1
}
```

从打印信息的到如果是strong类型声明的话，可变字符串赋值的后 model.name实际类型变成了NSMutableString类型。这不是我们想要的结果，显然对于model来说name属性的类型不想因为外界的赋值而改变，也不想因为外界的值改变了，model.name的值也跟着改变。

**总结：**
- 使用NSString赋值，使用copy或strong声明都可以
- 使用NSMutableString赋值，copy声明不会改变原类型（[可变字符串 copy]得到的是NSString类型），也不会跟随外界赋的值而改变。使用strong声明就会。

#### 重写Setter方法

当然有一种周全的方法，即便你是copy还是strong声明，赋值的是NSString还是NSMutableString类型，都不想外界修改的话。你可以重写setName:方法，例如：

```ObjC
- (void)setName:(NSString *)name{
    NSLog(@"%p", name);
    _name = [name copy];
    NSLog(@"%p", _name);
}
```

测试：

- 使用copy方式：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];

    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    model.name = stringM;

    // copy
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x6040000564d0
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke追加--0x6040000564d0
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // model.name是否是NSMutableString类型：0
}
```


- strong方式：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];

    NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"daisuke"];
    model.name = stringM;

    // strong
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke--0x604000445880
    [stringM appendString:@"追加"];
    NSLog(@"%@--%p--%@--%p", model.name, model.name, stringM, stringM);
    // daisuke--0xa656b75736961647--daisuke追加--0x604000445880
    NSLog(@"model.name是否是NSMutableString类型：%@", @([model.name isKindOfClass:[NSMutableString class]]));
    // model.name是否是NSMutableString类型：0
}
```


显然，重写了setName:方法并对name进行了copy操作，无论是copy还是strong声明，赋值的是NSString还是NSMutableString类型，都不会受到外界影响，所以应该养成这个习惯，这样就万无一失了。

#### 可变类型

CopyOrStrongModel声明两个属性：

```ObjC
@property (nonatomic, strong) NSMutableString *mutableString1;
@property (nonatomic, copy) NSMutableString *mutableString2;
```


测试：

```ObjC
- (void)viewDidLoad {
    [super viewDidLoad];

    CopyOrStrongModel *model = [[CopyOrStrongModel alloc] init];

    NSMutableString *string = @"daisuke".mutableCopy;
    model.mutableString1 = string;
    model.mutableString2 = string;

    NSLog(@"strong声明的model.mutableString1的类型是否是NSMutableString： %@", @([model.mutableString1 isKindOfClass:[NSMutableString class]]));
    // strong声明的model.mutableString1的类型是否是NSMutableString： 1
    NSLog(@"copy声明的model.mutableString1的类型是否是NSMutableString： %@", @([model.mutableString2 isKindOfClass:[NSMutableString class]]));
    // copy声明的model.mutableString1的类型是否是NSMutableString： 0

}
```

> 注意：使用copy声明NSMutableString类型的属性，实际得到的是NSString类型



### 参考文档
- [Copying Collections](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Collections/Articles/Copying.html#//apple_ref/doc/uid/TP40010162-SW3)
- [NSCopying](https://developer.apple.com/library/archive/documentation/LegacyTechnologies/WebObjects/WebObjects_3.5/Reference/Frameworks/ObjC/Foundation/Protocols/NSCopying/Description.html#//apple_ref/occ/intfm/NSCopying/copyWithZone:)
- [ios 深度复制 copy & mutablecopy](https://www.cnblogs.com/loying/p/4862275)

