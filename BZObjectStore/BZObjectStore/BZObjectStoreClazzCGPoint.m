//
// The MIT License (MIT)
//
// Copyright (c) 2014 BONZOO.LLC
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

#import "BZObjectStoreClazzCGPoint.h"
#import "FMResultSet.h"
#import "BZObjectStoreConst.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreSQLiteColumnModel.h"

@implementation BZObjectStoreClazzCGPoint

- (NSString*)attributeType
{
    return @"CGPoint";
}
- (BOOL)isSimpleValueClazz
{
    return YES;
}

- (NSArray*)sqliteColumnsWithAttribute:(BZObjectStoreRuntimeProperty *)attribute
{
    BZObjectStoreSQLiteColumnModel *x = [[BZObjectStoreSQLiteColumnModel alloc]init];
    x.columnName = [NSString stringWithFormat:@"%@_x",attribute.columnName];
    x.dataTypeName = [self sqliteDataTypeName];
    
    BZObjectStoreSQLiteColumnModel *y = [[BZObjectStoreSQLiteColumnModel alloc]init];
    y.columnName = [NSString stringWithFormat:@"%@_y",attribute.columnName];
    y.dataTypeName = [self sqliteDataTypeName];
    
    return @[x,y];
}

- (NSArray*)storeValuesWithObject:(NSObject*)object attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSValue *value = [object valueForKey:attribute.name];
    CGPoint point = [value CGPointValue];
    NSNumber *x = [NSNumber numberWithDouble:point.x];
    NSNumber *y = [NSNumber numberWithDouble:point.y];
    return @[x,y];
}

- (id)valueWithResultSet:(FMResultSet*)resultSet attribute:(BZObjectStoreRuntimeProperty*)attribute
{
    NSString *columnNameX = [NSString stringWithFormat:@"%@_x",attribute.columnName];
    NSString *columnNameY = [NSString stringWithFormat:@"%@_y",attribute.columnName];
    CGPoint point;
    point.x = [resultSet doubleForColumn:columnNameX];
    point.y = [resultSet doubleForColumn:columnNameY];
    return [NSValue valueWithCGPoint:point];
    
}

- (NSString*)sqliteDataTypeName
{
    return SQLITE_DATA_TYPE_INTEGER;
}

@end
