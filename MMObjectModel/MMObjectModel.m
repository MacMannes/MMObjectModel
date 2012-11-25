//
//  MMObjectModel.h
//  MMObjectModel
//
//  Created by André Mathlener on 18-03-12.
//  Copyright (c) 2012 MacMannes. All rights reserved.

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "MMObjectModel.h"
#import <objc/runtime.h>

@implementation MMObjectModel

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [super init])) {
        _objectModelKeys = [self allObjectModelKeys];
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (id)initWithJSONData: (NSData *)jsonData
{
    NSError *jsonError;
    NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    if (jsonError) {
        return nil;
    } else {
        return [self initWithDictionary:jsonDict];
    }
}

- (id)initWithXMLData:(NSData *)xmlData
{
    return [self initWithXMLData:xmlData rootElement:nil];
}

- (id)initWithXMLData:(NSData *)xmlData rootElement:(NSString *)rootElement
{
    MMXMLReader *reader = [[MMXMLReader alloc] initWithData:xmlData];
    if (reader) {
        NSMutableDictionary *xmlDict = [reader convertToDictionary];
        if (xmlDict) {
            if (rootElement) {
                NSMutableDictionary *rootDict = [xmlDict objectForKey:rootElement];
                if (rootDict) {
                    return [self initWithDictionary:rootDict];
                }
            } else {
                return [self initWithDictionary:xmlDict];
            }
        }
    }
    
    return nil;
    
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *className = [self classNameForKey:key];
    if (className) {
        __strong Class valueClass = [[NSClassFromString(className) alloc] initWithDictionary:value];
        [super setValue:valueClass forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    MMLog(@"Undefined key: %@", key);
}

- (id)valueForKey:(NSString *)key
{
    id value = [super valueForKey:key];
    if ([value isKindOfClass:[MMObjectModel class]]) {
        return (MMObjectModel *)[value dictionary];
    } else if ([value isKindOfClass:[NSArray class]]) {
        NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[value count]];
        for (id object in value) {
            if ([object isKindOfClass:[MMObjectModel class]]) {
                [returnArray addObject:(MMObjectModel *)[object dictionary]];
            } else {
                [returnArray addObject:value];
            }
        }
        return returnArray;
    }
    return value;
}

- (NSArray *)allKeys
{
    u_int count;
    
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    return [NSArray arrayWithArray:propertyArray];
}

- (NSMutableDictionary *)allObjectModelKeys
{
    NSMutableDictionary* returnDictionary = [[NSMutableDictionary alloc] init];
    
    u_int count=0;
    objc_property_t *props = class_copyPropertyList([self class],&count);
    for (int i = 0; i < count; i++) {
        const char *name = property_getName(props[i]);
        const char *attr = property_getAttributes(props[i]);
        NSString *attributtes = [NSString stringWithCString:attr encoding:NSUTF8StringEncoding];
        if ([attributtes hasPrefix:@"T@"]) {
            NSScanner *scanner = [NSScanner scannerWithString:attributtes];
            NSString *className;
            [scanner scanUpToString:@"\"" intoString:nil];
            [scanner scanString:@"\"" intoString:nil];
            [scanner scanUpToString:@"\"" intoString:&className];
            if (className) {
                Class myClass = NSClassFromString(className);
                if ([myClass isSubclassOfClass:[MMObjectModel class]]) {
                    [returnDictionary setValue:NSStringFromClass(myClass) forKey:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    free(props);
    
    return returnDictionary;
}

- (NSString *)classNameForKey:(NSString *)aKey
{
    for (NSString *key in [_objectModelKeys allKeys]) {
        if ([key compare:aKey options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [_objectModelKeys objectForKey:key];
        }
    }
    
    return nil;
}

- (NSArray *)arrayForObject:(id)object
{
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    } else {
        return [NSArray arrayWithObject:object];
    }
}

- (NSArray *)convertObjectsOfArray:(NSArray *)array toClass:(id)objectModelClass
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    for (id item in array) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            __strong Class objectModel = [[objectModelClass alloc] initWithDictionary:item];
            [returnArray addObject:objectModel];
        }
    }
    return returnArray;
}

- (NSDictionary *)dictionary
{
    return [self dictionaryWithValuesForKeys:[self allKeys]];
}

- (NSData *)jsonData
{
    return  [NSJSONSerialization dataWithJSONObject:[self dictionary]
                                            options:kNilOptions error:nil];
}

- (NSData *)prettyJsonData
{
    return  [NSJSONSerialization dataWithJSONObject:[self dictionary]
                                            options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString *)jsonString
{
    return [[NSString alloc] initWithData:[self jsonData]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)prettyJsonString
{
    return [[NSString alloc] initWithData:[self prettyJsonData]
                                 encoding:NSUTF8StringEncoding];
}

- (NSString *)description
{
    return [self jsonString];
}

@end
