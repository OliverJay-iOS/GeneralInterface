//
//  CoreDataInterface.h
//  EMTest
//
//  Created by mac  on 14-8-20.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum
{
    INT_TYPE = 0,
    STRING_TYPE = 1,
    BINARYDATA_TYPE = 2,
    BOOL_TYPE = 3,
    DATE_TYPE = 4,
    FLOAT_TYPE = 5,
    DOUBLE_TYPE = 6
} CORE_DATA_ATTRIBUTE_TYPE;



@interface CoreDataResponseInfo : NSObject

@property (strong, nonatomic)NSError *       error;
@property (strong, nonatomic)NSString * responseString;
@property (strong, nonatomic)id result;
@property BOOL bSuccess;

@end


@interface CoreDataAttributeInfo : NSObject

@property CORE_DATA_ATTRIBUTE_TYPE   dataType;
@property (strong, nonatomic) NSString * attributeName;
@property (strong, nonatomic) id attributeValue;
@property (strong, nonatomic) id defaultValue;

@end



@interface CoreDataInterface : NSObject{
    @public
    UIManagedDocument * managedDocument;
    NSURL *storeURL;
    
}

@property (nonatomic,strong) NSManagedObjectContext* context ;

- (CoreDataResponseInfo *)saveContext;

- (NSEntityDescription *)getEntityByEntityName:(NSString *)entityName;

//用代码生成entity并且用它初初化NSManagedObjectModel
- (NSManagedObjectModel *)createModelWithName:(NSString *)entityName attributeInfos:(NSArray *)attributeInfos ;

//用momd文件来生成NSManagerObjectModel
- (NSManagedObjectModel *)createModelWithMomd:(NSString *)momdName;

- (CoreDataResponseInfo *)addValuesWithEntityName:(NSString *)entityName
                                           values:(NSArray *)attributeInfos;

//conditions包括各个查询条件的key和value值，将根据这些键值对来找出对应序列并且删除它
- (CoreDataResponseInfo *)deleteObjectWithQueryCondition:(NSMutableDictionary *)conditions entityName:(NSString *)entityName;

//根据指定conditions条件来查出对应数据，并对之作update更新。
- (CoreDataResponseInfo *)updateObjectWithQueryCondition:(NSMutableDictionary *)conditions entityName:(NSString *)entityName changeKeyValues:(NSMutableDictionary *)keyValues;

/*
 查询指定键值对的信息。
 count:指定返回的数据条数;
 batchCount如传小于等于0的数 则将全部数据传回。
 offsetCount可传0
 */
- (CoreDataResponseInfo *)queryObjectWithQueryCondition:(NSMutableDictionary *)conditions withEntityName:(NSString *)entityName batchCount:(int)batchCount offsetCount:(int)offsetCount;

/*
 manageObjects:要删除的objects
 bSave:是否要将context中删除的数据，落地到本地sqlite中。
 */
- (CoreDataResponseInfo *)deleteObjects:(NSArray *)manageObjects bSave:(BOOL)bSave;



@end









