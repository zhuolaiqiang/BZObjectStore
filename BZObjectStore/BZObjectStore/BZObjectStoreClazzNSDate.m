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

#import "BZObjectStoreClazzNSDate.h"
#import "FMResultSet.h"
#import "BZObjectStoreConst.h"

@implementation BZObjectStoreClazzNSDate

- (Class)superClazz
{
    return [NSDate class];
}
- (NSString*)attributeType
{
    return NSStringFromClass([self superClazz]);
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}
- (BOOL)isStringNumberClazz
{
    return YES;
}

- (id)storeValueWithValue:(NSObject*)value
{
    if ([[value class] isSubclassOfClass:[NSDate class]]) {
        return value;
    } else {
        return [NSNull null];
    }
}

- (id)valueWithStoreValue:(NSObject*)value
{
    if ([[value class] isSubclassOfClass:[NSDate class]]) {
        return value;
    }
    return nil;
}

- (id)storeValueWithObject:(NSObject*)object name:(NSString*)name
{
    return [self storeValueWithValue:[object valueForKey:name]];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet colunmName:(NSString*)columnName
{
    return [self valueWithStoreValue:[resultSet dateForColumn:columnName]];
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_DATETIME;
}

@end