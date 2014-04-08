//
// The MIT License (MIT)
//
// Copyright (c) 2014 BONZOO LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <XCTest/XCTest.h>
#import <float.h>
#import <limits.h>
#import "ColorUtils.h"
#import "BZObjectStoreOnDisk.h"
#import "BZObjectStoreOnMemory.h"
#import "BZVarietyValuesModel.h"
#import "BZVarietyValuesItemModel.h"
#import "BZInvalidValuesModel.h"
#import "BZRelationshipHeaderModel.h"
#import "BZRelationshipDetailModel.h"
#import "BZRelationshipItemModel.h"
#import "BZResponseModel.h"
#import "BZCircularReferenceModel.h"

@interface BZObjectStoreTests : XCTestCase

@end

@implementation BZObjectStoreTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test
{
    BZObjectStore *disk = [BZObjectStoreOnDisk sharedInstance];
    [self testBZVarietyValuesModel:disk];
    [self testBZInvalidValuesModel:disk];
    [self testBZRelationshipHeaderModel:disk];
    [self testBZResponseModel:disk];
    [self testCircularReference:disk];
    
    BZObjectStore *memory = [BZObjectStoreOnMemory sharedInstance];
    [self testBZVarietyValuesModel:memory];
    [self testBZInvalidValuesModel:memory];
    [self testBZRelationshipHeaderModel:memory];
    [self testBZResponseModel:memory];
    [self testCircularReference:memory];
}

- (void)testBZVarietyValuesModel:(BZObjectStore*)os
{
    // setup models
    BZVarietyValuesItemModel *item1 = [[BZVarietyValuesItemModel alloc]init];
    item1.code = @"01";
    item1.name = @"apple";

    BZVarietyValuesItemModel *item2 = [[BZVarietyValuesItemModel alloc]init];
    item2.code = @"02";
    item2.name = @"orange";

    BZVarietyValuesItemModel *item3 = [[BZVarietyValuesItemModel alloc]init];
    item3.code = @"03";
    item3.name = @"banana";

    BZVarietyValuesModel *savedObject = [[BZVarietyValuesModel alloc]init];
    
    foo vvalue = {2,"name",1.23456788f};

    // POD types
    savedObject.vbool_max = YES;
    savedObject.vdouble_max = DBL_MAX;
    savedObject.vfloat_max = FLT_MAX;
    savedObject.vchar_max = CHAR_MAX;
    savedObject.vint_max = INT_MAX;
    savedObject.vshort_max = SHRT_MAX;
    savedObject.vlong_max = LONG_MAX;
    savedObject.vlonglong_max = LLONG_MAX;
    savedObject.vunsignedchar_max = UCHAR_MAX;
    savedObject.vunsignedint_max = UINT_MAX;
    savedObject.vunsignedshort_max = USHRT_MAX;
    savedObject.vunsignedlong_max = ULONG_MAX;
    savedObject.vunsignedlonglong_max = ULLONG_MAX;
    savedObject.vbool_min = NO;
    savedObject.vdouble_min = DBL_MIN;
    savedObject.vfloat_min = FLT_MIN;
    savedObject.vchar_min = CHAR_MIN;
    savedObject.vint_min = INT_MIN;
    savedObject.vshort_min = SHRT_MIN;
    savedObject.vlong_min = LONG_MIN;
    savedObject.vlonglong_min = LLONG_MIN;
    savedObject.vunsignedchar_min = 0;
    savedObject.vunsignedint_min = 0;
    savedObject.vunsignedshort_min = 0;
    savedObject.vunsignedlong_min = 0;
    savedObject.vunsignedlonglong_min = 0;
    savedObject.vfoo = vvalue;
    
    // objective-c
    savedObject.vnsinteger = 99;
    savedObject.vstring = @"string";
    savedObject.vrange = NSMakeRange(1, 2);
    savedObject.vmutableString = [NSMutableString stringWithString:@"mutableString"];
    savedObject.vnumber = [NSNumber numberWithBool:YES];
    savedObject.vurl = [NSURL URLWithString:@"http://wwww.yahoo.com"];
    savedObject.vnull = [NSNull null];
    savedObject.vcolor = [UIColor redColor];
    savedObject.vimage = [UIImage imageNamed:@"AppleLogo.png"];
    savedObject.vdata = [NSData dataWithData:UIImagePNGRepresentation(savedObject.vimage)];
    savedObject.vid = item2;
    savedObject.vmodel = item3;
    savedObject.vvalue = [NSValue value:&vvalue withObjCType:@encode(foo)];
    
    // objective-c core graphics
    savedObject.vcgfloat = 44.342334f;
    savedObject.vrect = CGRectMake(4.123456f,1.123456f,2.123456f,3.123456f);
    savedObject.vpoint = CGPointMake(4.123456f, 5.123456f);
    savedObject.vsize = CGSizeMake(6.123456f, 7.123456f);

    // objective-c array,set,dictionary,orderedset
    savedObject.vArray = [NSArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vSet = [NSSet setWithObjects:item1,item2,item3, nil];
    savedObject.vdictionary = [NSDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vOrderedSet = [NSOrderedSet orderedSetWithObjects:item1,item3, nil];
    savedObject.vmutableArray = [NSMutableArray arrayWithObjects:item1,item2,item3, nil];
    savedObject.vmutableSet = [NSMutableSet setWithObjects:item1,item2,item3, nil];
    savedObject.vmutabledictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:item1,item1.name,item3,item3.name, nil];
    savedObject.vmutableOrderedSet = [NSMutableOrderedSet orderedSetWithObjects:item1,item3, nil];
    
    // save object
    NSError *error = nil;
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    // fetch object
    NSArray *fetchedObjects = [os fetchObjects:[BZVarietyValuesModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue(fetchedObjects.count == 1, @"fetch objects count is invalid");

    
    
    
    // variable simple value tests
    BZVarietyValuesModel *fetchedObject = fetchedObjects.firstObject;
    XCTAssertTrue(![fetchedObject isEqual:savedObject],"object error");

    
    // class type
    XCTAssertTrue([[savedObject.vstring class] isSubclassOfClass:[NSString class]], @"nsstring class");
    XCTAssertTrue([[savedObject.vmutableString class] isSubclassOfClass:[NSMutableString class]], @"vmutableString class");
    XCTAssertTrue([[savedObject.vvalue class] isSubclassOfClass:[NSValue class]], @"vvalue class");
    XCTAssertTrue([[savedObject.vnumber class] isSubclassOfClass:[NSNumber class]], @"vnumber class");
    XCTAssertTrue([[savedObject.vurl class] isSubclassOfClass:[NSURL class]], @"vurl class");
    XCTAssertTrue([[savedObject.vnull class] isSubclassOfClass:[NSNull class]], @"vnull class");
    XCTAssertTrue([[savedObject.vcolor class] isSubclassOfClass:[UIColor class]], @"vcolor class");
    XCTAssertTrue([[savedObject.vimage class] isSubclassOfClass:[UIImage class]], @"vimage class");
    XCTAssertTrue([[savedObject.vdata class] isSubclassOfClass:[NSData class]], @"vdata class");
    XCTAssertTrue([[savedObject.vArray class] isSubclassOfClass:[NSArray class]], @"vArray class");
    XCTAssertTrue([[savedObject.vSet class] isSubclassOfClass:[NSSet class]], @"vSet class");
    XCTAssertTrue([[savedObject.vdictionary class] isSubclassOfClass:[NSDictionary class]], @"vdictionary class");
    XCTAssertTrue([[savedObject.vOrderedSet class] isSubclassOfClass:[NSOrderedSet class]], @"vOrderedSet class");
    XCTAssertTrue([[savedObject.vmutableArray class] isSubclassOfClass:[NSArray class]], @"vmutableArray class");
    XCTAssertTrue([[savedObject.vmutableSet class] isSubclassOfClass:[NSSet class]], @"vmutableSet class");
    XCTAssertTrue([[savedObject.vmutabledictionary class] isSubclassOfClass:[NSDictionary class]], @"vmutabledictionary class");
    XCTAssertTrue([[savedObject.vmutableOrderedSet class] isSubclassOfClass:[NSOrderedSet class]], @"vmutableOrderedSet class");
    
    
    // POD types
    XCTAssertTrue(fetchedObject.vdouble_max == savedObject.vdouble_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vbool_max == savedObject.vbool_max,"vdouble_max error");
    XCTAssertTrue(fetchedObject.vfloat_max == savedObject.vfloat_max,"vfloat_max error");
    XCTAssertTrue(fetchedObject.vchar_max == savedObject.vchar_max,"vchar_max error");
    XCTAssertTrue(fetchedObject.vint_max == savedObject.vint_max,"vint_max error");
    XCTAssertTrue(fetchedObject.vshort_max == savedObject.vshort_max,"vshort_max error");
    XCTAssertTrue(fetchedObject.vlong_max == savedObject.vlong_max,"vlong_max error");
    XCTAssertTrue(fetchedObject.vlonglong_max == savedObject.vlonglong_max,"vlonglong_max error");
    XCTAssertTrue(fetchedObject.vunsignedchar_max == savedObject.vunsignedchar_max,"vunsignedchar_max error");
    XCTAssertTrue(fetchedObject.vunsignedint_max == savedObject.vunsignedint_max,"vunsignedint_max error");
    XCTAssertTrue(fetchedObject.vunsignedshort_max == savedObject.vunsignedshort_max,"vunsignedshort_max error");
    XCTAssertTrue(fetchedObject.vunsignedlong_max == savedObject.vunsignedlong_max,"vunsignedlong_max error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_max == savedObject.vunsignedlonglong_max,"vunsignedlonglong_max error");
    XCTAssertTrue(fetchedObject.vdouble_min == savedObject.vdouble_min,"vdouble_min error");
    XCTAssertTrue(fetchedObject.vbool_min == savedObject.vbool_min,"vbool_min error");
    XCTAssertTrue(fetchedObject.vfloat_min == savedObject.vfloat_min,"vfloat_min error");
    XCTAssertTrue(fetchedObject.vchar_min == savedObject.vchar_min,"vchar_min error");
    XCTAssertTrue(fetchedObject.vint_min == savedObject.vint_min,"vint_min error");
    XCTAssertTrue(fetchedObject.vshort_min == savedObject.vshort_min,"vshort_min error");
    XCTAssertTrue(fetchedObject.vlong_min == savedObject.vlong_min,"vlong_min error");
    XCTAssertTrue(fetchedObject.vlonglong_min == savedObject.vlonglong_min,"vlonglong_min error");
    XCTAssertTrue(fetchedObject.vunsignedchar_min == savedObject.vunsignedchar_min,"vunsignedchar_min error");
    XCTAssertTrue(fetchedObject.vunsignedint_min == savedObject.vunsignedint_min,"vunsignedint_min error");
    XCTAssertTrue(fetchedObject.vunsignedshort_min == savedObject.vunsignedshort_min,"vunsignedshort_min error");
    XCTAssertTrue(fetchedObject.vunsignedlong_min == savedObject.vunsignedlong_min,"vunsignedlong_min error");
    XCTAssertTrue(fetchedObject.vunsignedlonglong_min == savedObject.vunsignedlonglong_min,"vunsignedlonglong_min error");
    XCTAssertTrue(fetchedObject.vfoo.no == 2, @"struct int error");
    XCTAssertTrue(strcmp(fetchedObject.vfoo.name, "name") == 0, @"struct int error");
    XCTAssertTrue(fetchedObject.vfoo.average == 1.23456788f, @"struct double error");

    // objective-c
    XCTAssertTrue(fetchedObject.vnsinteger == savedObject.vnsinteger,"vinteger error");
    XCTAssertTrue([fetchedObject.vstring isEqualToString:savedObject.vstring],"vstring error");
    XCTAssertTrue(fetchedObject.vrange.length == savedObject.vrange.length,"vrange error");
    XCTAssertTrue(fetchedObject.vrange.location == savedObject.vrange.location,"vrange error");
    XCTAssertTrue([fetchedObject.vmutableString isEqualToString:savedObject.vmutableString],"vmutableString error");
    XCTAssertTrue([fetchedObject.vnumber isEqualToNumber:savedObject.vnumber],"vnumber error");
    XCTAssertTrue([fetchedObject.vcolor RGBAValue] == [[UIColor redColor] RGBAValue],@"vcolor error");
    XCTAssertTrue([[fetchedObject.vurl absoluteString] isEqualToString:[savedObject.vurl absoluteString]],@"vurl error");
    XCTAssertTrue(fetchedObject.vnull == [NSNull null],@"vmutableSet error");
    XCTAssertTrue([fetchedObject.vdata isEqualToData:[NSData dataWithData:UIImagePNGRepresentation(fetchedObject.vimage)]],@"vdata,vimage error");
    foo fetchedvvalue;
    [fetchedObject.vvalue getValue:&fetchedvvalue];
    XCTAssertTrue(fetchedvvalue.no == 2, @"struct int error");
    XCTAssertTrue(strcmp(fetchedvvalue.name, "name") == 0, @"struct int error");
    XCTAssertTrue(fetchedvvalue.average == 1.23456788f, @"struct double error");
    
    BZVarietyValuesItemModel *vidfrom = (BZVarietyValuesItemModel*)fetchedObject.vid;
    BZVarietyValuesItemModel *vidto = (BZVarietyValuesItemModel*)savedObject.vid;
    XCTAssertTrue([vidfrom.code isEqualToString:vidto.code] ,@"vdictionary error");
    XCTAssertTrue([vidfrom.name isEqualToString:vidto.name] ,@"vdictionary error");

    BZVarietyValuesItemModel *vmodelfrom = (BZVarietyValuesItemModel*)fetchedObject.vmodel;
    BZVarietyValuesItemModel *vmodelto = (BZVarietyValuesItemModel*)savedObject.vmodel;
    XCTAssertTrue([vmodelfrom.code isEqualToString:vmodelto.code] ,@"vdictionary error");
    XCTAssertTrue([vmodelfrom.name isEqualToString:vmodelto.name] ,@"vdictionary error");

    
    
    // objective-c core graphics
    XCTAssertTrue(fetchedObject.vcgfloat == savedObject.vcgfloat,"vfloat error");
    XCTAssertTrue(CGRectEqualToRect(fetchedObject.vrect,savedObject.vrect),@"vrect error");
    XCTAssertTrue(CGPointEqualToPoint(fetchedObject.vpoint,savedObject.vpoint),@"vpoint error");
    XCTAssertTrue(CGSizeEqualToSize(fetchedObject.vsize,savedObject.vsize),@"vsize error");
    
    // set,array,dictionary,orderedset count test
    XCTAssertTrue(fetchedObject.vmutableSet.count == 3,@"vmutableSet error");
    XCTAssertTrue(fetchedObject.vmutableArray.count == 3,@"vmutableArray error");
    XCTAssertTrue(fetchedObject.vmutabledictionary.count == 2,@"vmutabledictionary error");
    XCTAssertTrue(fetchedObject.vmutableOrderedSet.count == 2,@"vmutableOrderedSet error");
    XCTAssertTrue(fetchedObject.vSet.count == 3,@"vSet error");
    XCTAssertTrue(fetchedObject.vArray.count == 3,@"vArray error");
    XCTAssertTrue(fetchedObject.vdictionary.count == 2,@"vdictionary error");
    XCTAssertTrue(fetchedObject.vOrderedSet.count == 2,@"vOrderedSet error");
    
    //  array test
    {
        NSArray *fromList = fetchedObject.vArray;
        NSArray *toList = savedObject.vArray;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vArray error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vArray error");
        }
    }
    
    // dictionary test
    {
        NSArray *keys = fetchedObject.vdictionary.allKeys;
        for (NSString *key in keys) {
            BZVarietyValuesItemModel *from = [fetchedObject.vdictionary objectForKey:key];
            BZVarietyValuesItemModel *to = [savedObject.vdictionary objectForKey:key];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vdictionary error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vdictionary error");
        }
    }
    
    // set test
    {
        NSArray *fromList = fetchedObject.vSet.allObjects;
        NSArray *toList = savedObject.vSet.allObjects;
        fromList = [fromList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        toList = [toList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vSet error");
        }
    }
    
    // OrderedSet test
    {
        NSOrderedSet *fromList = fetchedObject.vOrderedSet;
        NSOrderedSet *toList = savedObject.vOrderedSet;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"OrderedSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"OrderedSet error");
        }
    }

    // mutable array test
    {
        NSArray *fromList = fetchedObject.vmutableArray;
        NSArray *toList = savedObject.vmutableArray;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutableArray error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutableArray error");
        }
    }
    
    // mutabledictionary test
    {
        NSArray *keys = fetchedObject.vmutabledictionary.allKeys;
        for (NSString *key in keys) {
            BZVarietyValuesItemModel *from = [fetchedObject.vmutabledictionary objectForKey:key];
            BZVarietyValuesItemModel *to = [savedObject.vmutabledictionary objectForKey:key];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutabledictionary error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutabledictionary error");
        }
    }

    // mutableset test
    {
        NSArray *fromList = fetchedObject.vmutableSet.allObjects;
        NSArray *toList = savedObject.vmutableSet.allObjects;
        fromList = [fromList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        toList = [toList sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            BZVarietyValuesItemModel *from = (BZVarietyValuesItemModel*)obj1;
            BZVarietyValuesItemModel *to = (BZVarietyValuesItemModel*)obj2;
            return [from.code compare:to.code];
        }];
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"vmutableSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"vmutableSet error");
        }
    }

    // mutableOrderedSet test
    {
        NSMutableOrderedSet *fromList = fetchedObject.vmutableOrderedSet;
        NSMutableOrderedSet *toList = savedObject.vmutableOrderedSet;
        for (NSInteger i = 0; i < fromList.count; i++ ) {
            BZVarietyValuesItemModel *from = fromList[i];
            BZVarietyValuesItemModel *to = toList[i];
            XCTAssertTrue([from.code isEqualToString:to.code] ,@"mutableOrderedSet error");
            XCTAssertTrue([from.name isEqualToString:to.name] ,@"mutableOrderedSet error");
        }
    }

    
}

- (void)testBZInvalidValuesModel:(BZObjectStore*)os
{
    BZInvalidValuesModel *savedObject = [[BZInvalidValuesModel alloc]init];
    savedObject.vclass = [BZInvalidValuesModel class];
    savedObject.vsel = @selector(testBZInvalidValuesModel:);
    
    NSError *error = nil;
    [os saveObject:savedObject error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *fetchedObjects = [os fetchObjects:[BZInvalidValuesModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    XCTAssertTrue(fetchedObjects.count == 1, @"count error");
}

- (void)testBZRelationshipHeaderModel:(BZObjectStore*)os
{
    BZRelationshipItemModel *item1 = [[BZRelationshipItemModel alloc]init];
    item1.code = @"item1";
    item1.price = 100;

    BZRelationshipItemModel *item2 = [[BZRelationshipItemModel alloc]init];
    item2.code = @"item2";
    item2.price = 200;
    item2.items = @[item1,item1];

    BZRelationshipDetailModel *detail1 = [[BZRelationshipDetailModel alloc]init];
    detail1.code = @"detail01";
    detail1.item = item1;
    detail1.count = 2;

    BZRelationshipDetailModel *detail2 = [[BZRelationshipDetailModel alloc]init];
    detail2.code = @"detail02";
    detail2.item = item2;
    detail2.count = 2;

    BZRelationshipHeaderModel *header = [[BZRelationshipHeaderModel alloc]init];
    header.code = @"header01";
    header.details = @[detail1,detail2];

    
    NSError *error = nil;
    [os saveObject:header error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *fetchedObjects = [os fetchObjects:[BZRelationshipHeaderModel class] condition:nil error:&error];
    XCTAssertTrue(fetchedObjects.count == 1, @"relationship count error");
    
    BZRelationshipHeaderModel *fetchedHeader = fetchedObjects.firstObject;
    XCTAssertTrue(fetchedHeader.details.count == 2, @"sub array count error");
    
    BZRelationshipDetailModel *fetchedDetail = fetchedHeader.details.lastObject;
    XCTAssertTrue(fetchedDetail.item.items.count == 2, @"sub sub array count error");

    [os removeObject:fetchedHeader error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *headerCount = [os count:[BZRelationshipHeaderModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([headerCount integerValue] == 0, @"header count error");

    NSNumber *detailCount = [os count:[BZRelationshipDetailModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([detailCount integerValue] == 0, @"header count error");

    NSNumber *itemCount = [os count:[BZRelationshipItemModel class] condition:nil error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    XCTAssertTrue([itemCount integerValue] == 0, @"header count error");

}

- (void)testBZResponseModel:(BZObjectStore*)os
{
    NSError *error = nil;
    NSMutableArray *list = [NSMutableArray array];
    for (NSInteger i = 0; i < 100000; i++ ) {
        BZResponseModel *model = [[BZResponseModel alloc]init];
        model.code = [NSString stringWithFormat:@"%d",i];
        model.name = [NSString stringWithFormat:@"name %d",i];
        model.address = [NSString stringWithFormat:@"address %d",i];
        model.birthday = [NSDate date];
        [list addObject:model];
    }
    
    NSDate *now = [NSDate date];
    [os saveObjects:list error:&error];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    NSDate *then = [NSDate date];
    NSLog(@"reponse then - now: %1.3fsec", [then timeIntervalSinceDate:now]);
}

- (void)testCircularReference:(BZObjectStore*)os
{
    NSError *error = nil;
    
    BZCircularReferenceModel *p1 = [[BZCircularReferenceModel alloc]initWithId:@"10" name:@"Yamada Taro" birthday:[NSDate date]];
    BZCircularReferenceModel *p2 = [[BZCircularReferenceModel alloc]initWithId:@"20" name:@"Yamada Hanako" birthday:[NSDate date]];
    BZCircularReferenceModel *p3 = [[BZCircularReferenceModel alloc]initWithId:@"30" name:@"Yamada Ichiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p4 = [[BZCircularReferenceModel alloc]initWithId:@"40" name:@"Yamada Jiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p5 = [[BZCircularReferenceModel alloc]initWithId:@"50" name:@"Yamada Saburo" birthday:[NSDate date]];
    BZCircularReferenceModel *p6 = [[BZCircularReferenceModel alloc]initWithId:@"60" name:@"Yamada Shiro" birthday:[NSDate date]];
    BZCircularReferenceModel *p7 = [[BZCircularReferenceModel alloc]initWithId:@"70" name:@"Yamada Goro" birthday:[NSDate date]];
    p1.family = @[p2,p3];
    p1.familyReference = @[p4,p5];
    p1.familySerialize = @[p6,p7];
    p3.father = p1;
    p3.mother = p2;
    p4.father = p4;
    
    [os saveObjects:@[p4] error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObjects:@[p5] error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    [os saveObject:p1 error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSArray *list = [os fetchObjects:[BZCircularReferenceModel class] condition:nil error:nil];
    XCTAssertTrue(list.count == 5,"object error");
    
    [os removeObject:p1 error:nil];
    XCTAssert(!error, @"No implementation for \"%s\"", __PRETTY_FUNCTION__);
    
    NSNumber *count = [os count:[BZCircularReferenceModel class] condition:nil error:nil];
    XCTAssertTrue([count isEqualToNumber:@0],"object error");
    
}

@end