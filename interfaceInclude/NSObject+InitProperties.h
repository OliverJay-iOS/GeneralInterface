//
//  NSObject+InitProperties.h
//  EMTest
//
//  Created by mac  on 14-8-19.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (InitProperties)

- (void) initProperties ;

//采用array的方式拼凑数据时，应注意values的排列顺序应与对象的property声明顺序一致。
//- (BOOL) initPropertiesWithValues:(NSArray *)values;

- (BOOL) initPrepertiesWithKeysAndValues:(NSMutableDictionary *)keyValues;

- (NSMutableDictionary *)turnToDictionary;

- (BOOL) getValueFromDictionary:(NSDictionary *)dictionary;



@end
