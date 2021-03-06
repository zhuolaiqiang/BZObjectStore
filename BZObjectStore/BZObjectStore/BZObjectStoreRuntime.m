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

#import "BZObjectStoreRuntime.h"
#import "BZObjectStoreClazz.h"
#import "BZObjectStoreRuntimeProperty.h"
#import "BZObjectStoreNameBuilder.h"
#import "BZObjectStoreConst.h"
#import "BZObjectStoreConditionModel.h"
#import "BZObjectStoreQueryBuilder.h"
#import "BZObjectStoreReferenceModel.h"
#import "BZRuntime.h"

@interface BZObjectStoreRuntime ()
@property (nonatomic,strong) BZObjectStoreClazz *osclazz;
@property (nonatomic,strong) NSString *selectTemplateStatement;
@property (nonatomic,strong) NSString *updateTemplateStatement;
@property (nonatomic,strong) NSString *selectRowidTemplateStatement;
@property (nonatomic,strong) NSString *insertIntoTemplateStatement;
@property (nonatomic,strong) NSString *insertOrIgnoreIntoTemplateStatement;
@property (nonatomic,strong) NSString *deleteFromTemplateStatement;
@property (nonatomic,strong) NSString *createTableTemplateStatement;
@property (nonatomic,strong) NSString *createUniqueIndexTemplateStatement;
@property (nonatomic,strong) NSString *dropIndexTemplateStatement;
@property (nonatomic,strong) NSString *countTemplateStatement;
@property (nonatomic,strong) NSString *referencedCountTemplateStatement;
@property (nonatomic,strong) NSString *uniqueIndexNameTemplateStatement;
@property (nonatomic,assign) BOOL hasNotUpdateIfValueIsNullAttribute;
@end

@implementation BZObjectStoreRuntime

+ (instancetype)runtimeWithClazz:(Class)clazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    @synchronized(self) {
        static id _runtimes = nil;
        if (!_runtimes) {
            _runtimes = [NSMutableDictionary dictionary];
        }
        Class targetClazz = NULL;
        BZObjectStoreClazz *osclazz = [BZObjectStoreClazz osclazzWithClazz:clazz];
        if (osclazz.isObjectClazz) {
            targetClazz = clazz;
        } else {
            targetClazz = osclazz.superClazz;
        }
        BZObjectStoreRuntime *runtime = [_runtimes objectForKey:NSStringFromClass(targetClazz)];
        if (!runtime) {
            runtime = [[self alloc]initWithClazz:targetClazz osclazz:osclazz nameBuilder:nameBuilder];
            [_runtimes setObject:runtime forKey:NSStringFromClass(targetClazz)];
        }
        return runtime;
    }
}


- (instancetype)initWithClazz:(Class)clazz osclazz:(BZObjectStoreClazz*)osclazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    if (self = [super init]) {
        [self setupWithClazz:clazz osclazz:osclazz nameBuilder:nameBuilder];
    }
    return self;
}

- (void)setupWithClazz:(Class)clazz osclazz:(BZObjectStoreClazz*)osclazz nameBuilder:(BZObjectStoreNameBuilder*)nameBuilder
{
    // clazz
    self.clazz = clazz;
    self.clazzName = NSStringFromClass(clazz);
    
    // mapper
    self.osclazz = osclazz;
    self.isArrayClazz = self.osclazz.isArrayClazz;
    self.isObjectClazz = self.osclazz.isObjectClazz;
    self.isSimpleValueClazz = self.osclazz.isSimpleValueClazz;
    self.isRelationshipClazz = self.osclazz.isRelationshipClazz;
    
    if (!self.isObjectClazz) {
        return;
    }
    
    // table name and column name for query builder
    self.nameBuilder = nameBuilder;
    self.tableName = [self.nameBuilder tableName:self.clazz];

    // class options
    self.fullTextSearch =  [self.clazz conformsToProtocol:@protocol(OSFullTextSearch)];
    if ([self.clazz conformsToProtocol:@protocol(OSModelInterface)]) {
        NSObject *object = [[self.clazz alloc]init];
        if ([object respondsToSelector:@selector(OSModelDidSave)]) {
            self.modelDidSave = YES;
        }
        if ([object respondsToSelector:@selector(OSModelDidRemove)]) {
            self.modelDidRemove = YES;
        }
        if ([object respondsToSelector:@selector(OSModelDidLoad)]) {
            self.modelDidLoad = YES;
        }
    }
    
    // attributes
    BZRuntime *bzruntime = nil;
    if ([self.clazz conformsToProtocol:@protocol(OSIgnoreSuperClass)]) {
        bzruntime = [BZRuntime runtimeWithClass:self.clazz];
    } else {
        bzruntime = [BZRuntime runtimeSuperClassWithClass:self.clazz];
    }
    NSMutableArray *propertyList = [NSMutableArray array];
    for (BZRuntimeProperty *property in bzruntime.propertyList) {
        NSString *from = [property.name uppercaseString];
        if (![from isEqualToString:@"ROWID"]) {
            BOOL exists = NO;
            for (BZRuntimeProperty *existingProperty in propertyList) {
                NSString *to = [existingProperty.name uppercaseString];
                if ([from isEqualToString:to]) {
                    exists = YES;
                    break;
                }
            }
            if (!exists) {
                [propertyList addObject:property];
            }
        }
    }
    NSMutableArray *insertAttributes = [NSMutableArray array];
    NSMutableArray *identicalAttributes = [NSMutableArray array];
    NSMutableArray *updateAttributes = [NSMutableArray array];
    NSMutableArray *relationshipAttributes = [NSMutableArray array];
    NSMutableArray *simpleValueAttributes = [NSMutableArray array];
    for (BZRuntimeProperty *property in propertyList) {
        BZObjectStoreRuntimeProperty *objectStoreAttribute = [BZObjectStoreRuntimeProperty propertyWithBZProperty:property runtime:self];
        if (objectStoreAttribute.isValid) {
            if (!objectStoreAttribute.ignoreAttribute && !property.propertyType.isReadonly) {
                [insertAttributes addObject:objectStoreAttribute];
                if (objectStoreAttribute.identicalAttribute) {
                    [identicalAttributes addObject:objectStoreAttribute];
                } else {
                    if (!objectStoreAttribute.onceUpdateAttribute) {
                        [updateAttributes addObject:objectStoreAttribute];
                    }
                }
                if (objectStoreAttribute.notUpdateIfValueIsNullAttribute) {
                    self.hasNotUpdateIfValueIsNullAttribute = YES;
                }
                if (objectStoreAttribute.isRelationshipClazz) {
                    [relationshipAttributes addObject:objectStoreAttribute];
                }
                if (objectStoreAttribute.isSimpleValueClazz) {
                    [simpleValueAttributes addObject:objectStoreAttribute];
                }
            }
        }
    }
    
    BZRuntime *referenceRuntime = [BZRuntime runtimeWithClass:[BZObjectStoreReferenceModel class]];
    BZObjectStoreRuntimeProperty *rowidAttribute = [BZObjectStoreRuntimeProperty propertyWithBZProperty:referenceRuntime.propertyList.firstObject runtime:self];
    NSMutableArray *attributes = [NSMutableArray array];
    [attributes addObject:rowidAttribute];
    [attributes addObjectsFromArray:insertAttributes];
    [simpleValueAttributes addObject:rowidAttribute];
    
    self.rowidAttribute = rowidAttribute;
    self.attributes = [NSArray arrayWithArray:attributes];
    self.insertAttributes = [NSArray arrayWithArray:insertAttributes];
    self.updateAttributes = [NSArray arrayWithArray:updateAttributes];
    self.identificationAttributes = [NSArray arrayWithArray:identicalAttributes];
    self.relationshipAttributes = [NSArray arrayWithArray:relationshipAttributes];
    self.simpleValueAttributes = [NSArray arrayWithArray:simpleValueAttributes];

    // response
    if (self.identificationAttributes.count > 0) {
        self.hasIdentificationAttributes = YES;
    } else {
        self.hasIdentificationAttributes = NO;
    }
    if (self.relationshipAttributes.count > 0) {
        self.hasRelationshipAttributes = YES;
    } else {
        self.hasRelationshipAttributes = NO;
    }
    self.insertPerformance = [self.clazz conformsToProtocol:@protocol(OSInsertPerformance)];
    self.updatePerformance = [self.clazz conformsToProtocol:@protocol(OSUpdatePerformance)];
    
    if (self.insertPerformance == NO && self.updatePerformance == NO) {
        self.insertPerformance = YES;
    }
    
    // query
    self.selectTemplateStatement = [BZObjectStoreQueryBuilder selectStatement:self];
    self.updateTemplateStatement = [BZObjectStoreQueryBuilder updateStatement:self];
    self.selectRowidTemplateStatement = [BZObjectStoreQueryBuilder selectRowidStatement:self];
    self.insertIntoTemplateStatement = [BZObjectStoreQueryBuilder insertIntoStatement:self];
    self.insertOrIgnoreIntoTemplateStatement = [BZObjectStoreQueryBuilder insertOrIgnoreIntoStatement:self];
    self.deleteFromTemplateStatement = [BZObjectStoreQueryBuilder deleteFromStatement:self];
    self.createTableTemplateStatement = [BZObjectStoreQueryBuilder createTableStatement:self];
    self.createUniqueIndexTemplateStatement = [BZObjectStoreQueryBuilder createUniqueIndexStatement:self];
    self.dropIndexTemplateStatement = [BZObjectStoreQueryBuilder dropIndexStatement:self];
    self.countTemplateStatement = [BZObjectStoreQueryBuilder countStatement:self];
    self.referencedCountTemplateStatement = [BZObjectStoreQueryBuilder referencedCountStatement:self];
    self.uniqueIndexNameTemplateStatement = [BZObjectStoreQueryBuilder uniqueIndexName:self];
    
}

#pragma mark statement methods

- (NSString*)uniqueIndexName
{
    return self.uniqueIndexNameTemplateStatement;
}
- (NSString*)createTableStatement
{
    return self.createTableTemplateStatement;
}
- (NSString*)createUniqueIndexStatement
{
    return self.createUniqueIndexTemplateStatement;
}
- (NSString*)dropUniqueIndexStatement
{
    return self.dropIndexTemplateStatement;
}
- (NSString*)insertIntoStatement
{
    return self.insertIntoTemplateStatement;
}
- (NSString*)insertOrIgnoreIntoStatement
{
    return self.insertOrIgnoreIntoTemplateStatement;
}
- (NSString*)updateStatementWithObject:(NSObject*)object condition:(BZObjectStoreConditionModel*)condition
{
    if (self.hasNotUpdateIfValueIsNullAttribute) {
        NSMutableArray *attributes = [NSMutableArray array];
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            NSValue *value = [object valueForKey:attribute.name];
            if (value) {
                [attributes addObject:attribute];
            }
        }
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:[BZObjectStoreQueryBuilder updateStatement:self attributes:attributes]];
        [sql appendString:[BZObjectStoreQueryBuilder updateConditionStatement:condition]];
        return [NSString stringWithString:sql];
    } else {
        NSMutableString *sql = [NSMutableString string];
        [sql appendString:self.updateTemplateStatement];
        [sql appendString:[BZObjectStoreQueryBuilder updateConditionStatement:condition]];
        return [NSString stringWithString:sql];
    }
}
- (NSString*)selectStatementWithCondition:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.selectTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self]];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionOptionStatement:condition]];
    return [NSString stringWithString:sql];
}

- (NSString*)selectRowidStatement:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.selectRowidTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition]];
    return [NSString stringWithString:sql];
}


- (NSString*)deleteFromStatementWithCondition:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.deleteFromTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder deleteConditionStatement:condition]];
    return [NSString stringWithString:sql];
}

- (NSString*)referencedCountStatementWithCondition:(BZObjectStoreConditionModel*)condition
{
    NSString *conditionStatement = [BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self];
    NSString *sql = self.referencedCountTemplateStatement;
    sql = [NSString stringWithFormat:sql,conditionStatement];
    return sql;
}

- (NSString*)countStatementWithCondition:(BZObjectStoreConditionModel*)condition
{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:self.countTemplateStatement];
    [sql appendString:[BZObjectStoreQueryBuilder selectConditionStatement:condition runtime:self]];
    return [NSString stringWithString:sql];
}

- (NSString*)minStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    return [BZObjectStoreQueryBuilder minStatement:self columnName:columnName];
}

- (NSString*)maxStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    return [BZObjectStoreQueryBuilder maxStatement:self columnName:columnName];
}

- (NSString*)avgStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    return [BZObjectStoreQueryBuilder avgStatement:self columnName:columnName];
}

- (NSString*)totalStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    return [BZObjectStoreQueryBuilder totalStatement:self columnName:columnName];
}

- (NSString*)sumStatementWithColumnName:(NSString*)columnName condition:(BZObjectStoreConditionModel*)condition
{
    return [BZObjectStoreQueryBuilder sumStatement:self columnName:columnName];
}

#pragma marks unique condition

- (BZObjectStoreConditionModel*)rowidCondition:(NSObject*)object
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = [BZObjectStoreQueryBuilder rowidConditionStatement];
    condition.sqlite.parameters = [self rowidAttributeParameter:object];
    return condition;
}

- (BZObjectStoreConditionModel*)uniqueCondition:(NSObject*)object
{
    BZObjectStoreConditionModel *condition = [BZObjectStoreConditionModel condition];
    condition.sqlite.where = [BZObjectStoreQueryBuilder uniqueConditionStatement:self];
    condition.sqlite.parameters = [self identificationAttributesParameters:object];
    return condition;
}

#pragma marks parameter methods

- (NSMutableArray*)insertAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.insertAttributes) {
        [parameters addObjectsFromArray:[attribute storeValuesWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)insertOrIgnoreAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.insertAttributes) {
        [parameters addObjectsFromArray:[attribute storeValuesWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)updateAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    if (self.hasNotUpdateIfValueIsNullAttribute) {
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            NSObject *value = [object valueForKey:attribute.name];
            if (value) {
                [parameters addObjectsFromArray:[attribute storeValuesWithObject:object]];
            }
        }
    } else {
        for (BZObjectStoreRuntimeProperty *attribute in self.updateAttributes) {
            [parameters addObjectsFromArray:[attribute storeValuesWithObject:object]];
        }
    }
    return parameters;
}

- (NSMutableArray*)identificationAttributesParameters:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    for (BZObjectStoreRuntimeProperty *attribute in self.identificationAttributes) {
        [parameters addObjectsFromArray:[attribute storeValuesWithObject:object]];
    }
    return parameters;
}

- (NSMutableArray*)rowidAttributeParameter:(NSObject*)object
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObjectsFromArray:[self.attributes.firstObject storeValuesWithObject:object]];
    return parameters;
}


#pragma mark value mapper

- (id)object
{
    return [self.osclazz objectWithClazz:self.clazz];
}
- (NSEnumerator*)objectEnumeratorWithObject:(id)object
{
    return [self.osclazz objectEnumeratorWithObject:object];
}
- (NSArray*)keysWithObject:(id)object
{
    return [self.osclazz keysWithObject:object];
}
- (id)objectWithObjects:(NSArray*)objects keys:(NSArray*)keys initializingOptions:(NSString*)initializingOptions
{
    return [self.osclazz objectWithObjects:objects keys:keys initializingOptions:initializingOptions];
}

@end
