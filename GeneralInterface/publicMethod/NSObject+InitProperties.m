//
//  NSObject+InitProperties.m
//  EMTest
//
//  Created by mac  on 14-8-19.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "NSObject+InitProperties.h"
#include <objc/runtime.h>

@implementation NSObject (InitProperties)

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

- (void) initProperties {
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString * attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            NSString * type = [NSString stringWithUTF8String:getPropertyType(property)];
            NSString * name = [NSString stringWithUTF8String:property_getName(property)];
//            NSLog(@"getpropertytype =%@",type);
//            NSLog(@"attributes = %@",attributes);
            
            if([type isEqualToString:@"NSString"] || [type isEqualToString:@"NSMutableString"]){
                [self setValue:@"" forKey:name];
            }
            if([type isEqualToString:@"NSArray"]){
                [self setValue:[NSArray array] forKey:name];
            }
            if([type isEqualToString:@"NSMutableArray"]){
                [self setValue:[NSMutableArray array] forKey:name];
            }
            if([type isEqualToString:@"NSDictionary"]){
                [self setValue:[NSDictionary dictionary] forKey:name];
            }
            if([type isEqualToString:@"NSMutableDictionary"]){
                [self setValue:[NSMutableDictionary dictionary] forKey:name];
            }
            if([type isEqualToString:@"c"]){
                [self setValue:[NSNumber numberWithBool:YES] forKey:name];
            }
            if([type isEqualToString:@"id"]){
                [self setValue:@"" forKey:name];
            }
            if([type isEqualToString:@"f"]){
                [self setValue:[NSNumber numberWithFloat:0.0] forKey:name];
            }
            if([type isEqualToString:@"d"]){
                [self setValue:[NSNumber numberWithFloat:0.0] forKey:name];
            }
            if([type isEqualToString:@"i"]){
                [self setValue:[NSNumber numberWithFloat:0] forKey:name];
            }
        }
        free(propertyArray);
    }
}

- (BOOL) initPropertiesWithValues:(NSArray *)values{
    @autoreleasepool {
        unsigned int numberOfProperties = 0;
        objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
        for (NSUInteger i = 0; i < numberOfProperties; i++) {
            objc_property_t property = propertyArray[i];
            NSString * name = [NSString stringWithUTF8String:property_getName(property)];
            [self setValue:[values objectAtIndex:i] forKey:name];
        }
        free(propertyArray);
    }
    
    return YES;
}

- (BOOL) initPrepertiesWithKeysAndValues:(NSMutableDictionary *)keyValues
{
    @autoreleasepool {
        for (NSString * key in keyValues) {
            [self setValue:[keyValues objectForKey:key] forKey:key];
        }
    }
    
    return YES;
}

- (NSMutableDictionary *)turnToDictionary{
    NSMutableDictionary * keyValues = [NSMutableDictionary dictionary];
    unsigned int numberOfProperties = 0;
    
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString * name = [NSString stringWithUTF8String:property_getName(property)];
        [keyValues setValue:[self valueForKey:name] forKey:name];
    }
    free(propertyArray);
    
    return keyValues;
}

- (BOOL)getValueFromDictionary:(NSDictionary *)dictionary{
    unsigned int numberOfProperties = 0;
    objc_property_t *propertyArray = class_copyPropertyList([self class], &numberOfProperties);
    for (NSUInteger i = 0; i < numberOfProperties; i++) {
        objc_property_t property = propertyArray[i];
        NSString * name = [NSString stringWithUTF8String:property_getName(property)];
        [self setValue:[dictionary objectForKey:name] forKey:name];
    }
    free(propertyArray);
    
    return YES;
}

@end
