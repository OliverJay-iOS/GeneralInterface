//
//  CoreDataInterface.m
//  EMTest
//
//  Created by mac  on 14-8-20.
//  Copyright (c) 2014年 mac . All rights reserved.
//


#import "CoreDataInterface.h"
//#import "../../../MobileAttendance/MobileAttendance/model/DataBean.h"
//#import "../../../DiDiTouGu/DiDiTouGu/model/DataBean.h"

@implementation CoreDataResponseInfo

- (void)dealloc{
    NSLog(@"CoreDataResponseInfo 回收");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initVariables{
    _error = nil;
    _responseString = nil;
    _result = nil;
    _bSuccess = NO;
}

@end

@implementation CoreDataAttributeInfo

- (void)dealloc{
//    NSLog(@"CoreDataAttributeInfo 回收");
}

@end

@interface CoreDataInterface(){
    NSRecursiveLock *lock;
}

@end

@implementation CoreDataInterface

- (id)init{
    self = [super init];
    if(self){
        lock = [[NSRecursiveLock alloc] init];
        lock.name = @"coredata.lock";
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextWillSave:)
                                                     name:NSManagedObjectContextWillSaveNotification
                                                   object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextWillSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextWillSave:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self];
    }
    
    return self;
}

- (void)contextWillSave:(NSNotification *)notification
{
    NSManagedObjectContext *context = [notification object];
    NSSet *insertedObjects = [context insertedObjects];
    NSSet *updateedObjects = [context updatedObjects];
    
    NSLog(@"notification = %@",notification);
    if ([insertedObjects count])
    {
        NSLog(@"Context is about to save. Obtaining permanent IDs for new %lu inserted objects", (unsigned long)[insertedObjects count]);
        NSError *error = nil;
        BOOL success = [context obtainPermanentIDsForObjects:[insertedObjects allObjects] error:&error];
        if (!success)
        {
            NSLog(@"contestwiilsave = %@",error);
        }
    }
}

static NSManagedObjectModel * managedObjectModel = nil;
static NSPersistentStoreCoordinator *persistentStoreCoordinator = nil;
- (NSManagedObjectModel *)createModelWithMomd:(NSString *)momdName{
    [lock lock];
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    
    NSString *modelpath = [[NSBundle mainBundle] pathForResource:momdName ofType:@"mom"];
    if (modelpath == nil)
    {
        modelpath = [[NSBundle mainBundle] pathForResource:momdName ofType:@"momd"];
    }
    if (modelpath)
    {
        NSURL *momUrl = [NSURL fileURLWithPath:modelpath];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momUrl];
    }
    [lock unlock];
    
    return managedObjectModel;
}

- (NSAttributeType)getAttributeTypeFromType:(CORE_DATA_ATTRIBUTE_TYPE)type{
    NSAttributeType t = NSStringAttributeType;
    switch (type) {
        case INT_TYPE:
            t = NSInteger32AttributeType;
            break;
            
        case STRING_TYPE:
            t = NSStringAttributeType;
            break;
            
        case BINARYDATA_TYPE:
            t = NSBinaryDataAttributeType;
            break;
            
        case BOOL_TYPE:
            t = NSBooleanAttributeType;
            break;
            
        case DATE_TYPE:
            t = NSDateAttributeType ;
            break;
            
        case FLOAT_TYPE:
            t = NSFloatAttributeType;
            break;
            
        case DOUBLE_TYPE:
            t = NSDoubleAttributeType;
            break;
    }
    
    return t;
}

- (NSManagedObjectModel *)createModelWithName:(NSString *)entityName attributeInfos:(NSArray *)attributeInfos{
     [lock lock];
     
     if (managedObjectModel != nil) {
         return managedObjectModel;
     }
     
     managedObjectModel = [[NSManagedObjectModel alloc] init];
     
     NSEntityDescription *runEntity = [[NSEntityDescription alloc] init];
     [runEntity setName:entityName];
     [runEntity setManagedObjectClassName:entityName];
     
     NSMutableArray *properties = [NSMutableArray array];
     for (CoreDataAttributeInfo * info in attributeInfos) {
         NSAttributeDescription *dateAttribute = [[NSAttributeDescription alloc] init];
         [dateAttribute setName:info.attributeName];
         [dateAttribute setAttributeType:[self getAttributeTypeFromType:info.dataType]];
         //这个data字段的时间是在初始化的时候赋值的
         [dateAttribute setOptional:NO];
         [dateAttribute setDefaultValue:info.defaultValue];
         [properties addObject:dateAttribute];
     }
     
     [runEntity setProperties:properties];
     
     [managedObjectModel setEntities:[NSArray arrayWithObject:runEntity]];
     
     [lock unlock];
     
     return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    if(managedObjectModel == nil){
        return nil;
    }
    
    NSURL *URL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Model.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    NSDictionary *options =
                            @{
                            NSMigratePersistentStoresAutomaticallyOption:@(YES),
                            NSInferMappingModelAutomaticallyOption:@(YES),
                            NSSQLitePragmasOption:@{@"journal_mode":@"WAL"}
                            };
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                   configuration:nil
                                                                             URL:URL
                                                                         options:options
                                                                           error:&error];
    if (!store)
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return nil;
    }
    
    return persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectContext *)context{
    if (_context != nil) {
        return _context;
    }
    
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//        [_context setStalenessInterval:1.0];
        [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [_context performBlockAndWait:^{
            [_context setPersistentStoreCoordinator:coordinator];
        }];
    }
    
    return _context;
}

- (CoreDataResponseInfo *)saveContext{
    [lock lock];
   
    __autoreleasing CoreDataResponseInfo * cachedResponse = [[CoreDataResponseInfo alloc]init];
    __block NSError *error = nil;
    __block BOOL bSuccess = YES;
    [_context performBlockAndWait:^{
        bSuccess = [_context save:&error];
    }];
    NSLog(@"bsuccess saveContext = %i,%@,%@",bSuccess,_context,cachedResponse);
    
    if (!bSuccess) {
        NSLog(@"Could not cache the response = %@",error);
    }
    
    __autoreleasing CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    info.bSuccess = bSuccess;
    info.error = error;
    
    [lock unlock];
    
    return cachedResponse;
}

- (CoreDataResponseInfo *)addValuesWithEntityName:(NSString *)entityName
                            values:(NSArray *)attributeInfos
{
    [lock lock];
    
    NSManagedObjectContext *context = self.context;
    
    NSManagedObject * cachedResponse = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                                      inManagedObjectContext:context];
    for (CoreDataAttributeInfo * info in attributeInfos) {
        [cachedResponse setValue:info.attributeValue forKey:info.attributeName];
    }
    
    __block NSError *error = nil;
    __block BOOL bSuccess = YES;
    [context performBlockAndWait:^{
        bSuccess = [context save:&error];
    }];
    
    if (!bSuccess) {
        NSLog(@"Could not cache the response = %@",error);
    }
    
    __autoreleasing CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    info.bSuccess = bSuccess;
    info.error = error;
    
    [lock unlock];
    
    return info;
}

- (CoreDataResponseInfo *)queryObjectWithQueryCondition:(NSMutableDictionary *)conditions withEntityName:(NSString *)entityName batchCount:(int)batchCount offsetCount:(int)offsetCount
{
    [lock lock];
    
    __autoreleasing CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    NSManagedObjectContext *context = self.context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSString * condition = @"AND ";
    for (NSString * key in conditions.allKeys) {
        id value = [conditions objectForKey:key];
        if([value isKindOfClass:[NSString class]]){
            condition = [condition stringByAppendingString:[NSString stringWithFormat:@"%@ == '%@'",key ,value]];
        }
        if([value isKindOfClass:[NSNumber class]]){
            condition = [condition stringByAppendingString:[NSString stringWithFormat:@"%@ == %@",key ,value]];
        }
    }
    condition = [condition stringByReplacingCharactersInRange:[condition rangeOfString:@"AND"] withString:@""];
    condition = [condition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"查询条件 查询 = %@,%i",condition,condition.length);
    if (condition && condition.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
        [fetchRequest setPredicate:predicate];
    }
    
    if(batchCount > 0){
        [fetchRequest setFetchLimit:batchCount];
    }
    [fetchRequest setFetchOffset:offsetCount];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (!error && result && result.count > 0) {
        NSLog(@"results query = %@,%d",result,result.count);
        info.bSuccess = YES;
        info.result = result;
    }
    else{
        NSLog(@"results query error =%@,%@",error,self.context);
        info.bSuccess = NO;
        info.error = error;
    }
    
    [lock unlock];
    
    return info;
}

- (CoreDataResponseInfo *)updateObjectWithQueryCondition:(NSMutableDictionary *)conditions entityName:(NSString *)entityName changeKeyValues:(NSMutableDictionary *)keyValues
{
    [lock lock];
    NSLog(@"params 2 =%@,%@,%@",conditions,entityName,keyValues);
    
    CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    NSManagedObjectContext *context = self.context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    fetchRequest.returnsObjectsAsFaults = NO;
    
    NSString * condition = @"AND ";
    for (NSString * key in conditions.allKeys) {
        id value = [conditions objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            condition = [condition stringByAppendingString:[NSString stringWithFormat:@"%@ == '%@'",key , value]];
        }
        if ([value isKindOfClass:[NSNumber class]]) {
            condition = [condition stringByAppendingString:[NSString stringWithFormat:@"%@ == %@",key , value]];
        }
    }
    condition = [condition stringByReplacingCharactersInRange:[condition rangeOfString:@"AND"] withString:@""];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
    [fetchRequest setPredicate:predicate];
    
    __block NSError *error = nil;
    __block BOOL saveResult = YES;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject * obj in result) {
        for (NSString * key in keyValues.allKeys) {
            [obj setValue:[keyValues objectForKey:key] forKey:key];
        }
    }
    
    [context performBlockAndWait:^{
        saveResult = [context save:&error];
    }];
    
    if (error || !saveResult)
    {
        info.bSuccess = NO;
        info.error = error;
    }
    else {
        info.bSuccess = YES;
    }

    NSLog(@"results update2 = %@,%i",result,info.bSuccess);
    
    [lock unlock];
    
    return info;
}

- (CoreDataResponseInfo *)deleteObjectWithQueryCondition:(NSMutableDictionary *)conditions entityName:(NSString *)entityName
{
    [lock lock];
    
    __autoreleasing CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    NSManagedObjectContext *context = self.context;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    NSString * condition = @"AND ";
    for (NSString * key in conditions.allKeys) {
        condition = [condition stringByAppendingString:[NSString stringWithFormat:@"%@ == '%@'",key , [conditions objectForKey:key]]];
    }
    condition = [condition stringByReplacingCharactersInRange:[condition rangeOfString:@"AND"] withString:@""];
    
    NSLog(@"查询条件 删除 = %@",condition);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:condition];
    [fetchRequest setPredicate:predicate];
    
    __block NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in result) {
    	[_context deleteObject:managedObject];
    }
    
    __block BOOL saveResult = YES;
    [context performBlockAndWait:^{
        saveResult = [context save:&error];
        NSLog(@"更新1 = %i",saveResult);
    }];
    
    if (!saveResult) {
    	NSLog(@"删除失败");
        info.bSuccess = NO;
        info.error = error;
    }
    else {
        info.bSuccess = YES;
    }
    
    [lock unlock];
    
    return info;
}

- (CoreDataResponseInfo *)deleteObjects:(NSArray *)manageObjects bSave:(BOOL)bSave
{
    [lock lock];
    
    __autoreleasing CoreDataResponseInfo * info = [[CoreDataResponseInfo alloc]init];
    NSManagedObjectContext *context = self.context;
    
    for (NSManagedObject *managedObject in manageObjects) {
        [_context deleteObject:managedObject];
    }
    
    if (bSave) {
        __block BOOL saveResult = YES;
        __block NSError * error = nil;
        [context performBlockAndWait:^{
            saveResult = [context save:&error];
        }];
        
        if (!saveResult) {
            NSLog(@"删除失败");
            info.bSuccess = NO;
            info.error = error;
        }
        else {
            info.bSuccess = YES;
        }
    }
    else{
        info.bSuccess = YES;
        info.error = nil;
    }
    
    [lock unlock];
    
    return info;
}

- (NSEntityDescription *)getEntityByEntityName:(NSString *)entityName{
    NSEntityDescription * entity = nil;
    for (NSEntityDescription * entityDescription in managedObjectModel.entities) {
        if([entityDescription.name isEqualToString:entityName]){
            entity = entityDescription;
            break ;
        }
    }
    
    return entity;
}

@end























