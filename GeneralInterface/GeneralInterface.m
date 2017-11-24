//
//  GeneralInterface.m
//  GeneralInterface
//
//  Created by mac  on 14-8-13.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "GeneralInterface.h"

@interface GeneralInterface(){
    
}
@end

@implementation GeneralInterface

@synthesize manager;
@synthesize operationQueue;
@synthesize bAllowInvalidCertificates;             //是否允许跳过 客户端信作服务器步骤
@synthesize fTimeoutInterval;                      //超时时间
@synthesize responseType;

static GeneralInterface *sharedClient = nil;
+ (GeneralInterface *)Instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[GeneralInterface alloc] init];
        [sharedClient initConfig];
    });
    return sharedClient;
}

- (void)initConfig{
    manager = [AFHTTPRequestOperationManager manager];
    operationQueue = manager.operationQueue;
    bAllowInvalidCertificates = YES;
    fTimeoutInterval = 7;
    manager.requestSerializer.timeoutInterval = fTimeoutInterval;
    
    [manager.reachabilityManager startMonitoring];
    switch ([manager.reachabilityManager networkReachabilityStatus]) {
        case AFNetworkReachabilityStatusNotReachable:{
            if(NetChangeBlock){
                NetChangeBlock(manager.reachabilityManager.networkReachabilityStatus);
            }
        }
            break;
            
        case AFNetworkReachabilityStatusUnknown:{
            if(NetChangeBlock){
                NetChangeBlock(manager.reachabilityManager.networkReachabilityStatus);
            }
        }
            break;
            
        case AFNetworkReachabilityStatusReachableViaWWAN:
            operationQueue.maxConcurrentOperationCount = 2;
            break;
            
        case AFNetworkReachabilityStatusReachableViaWiFi:
            operationQueue.maxConcurrentOperationCount = 6;
            break;
            
        default:
            break;
    }
}

- (void)setResponseType:(RESPONSE_TYPE)type{
    switch (type) {
        case JSON_RESPONSE_TYPE:
            [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
            break;
            
        case XML_RESPONSE_TYPE:
            [manager setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
            break;
            
        case PROPERTYLIST_RESPONSE_TYPE:
            [manager setResponseSerializer:[AFPropertyListResponseSerializer serializer]];
            break;
            
        case IMAGE_RESPONSE_TYPE:
            [manager setResponseSerializer:[AFImageResponseSerializer serializer]];
            break;
            
        case COMPOUND_RESPONSE_TYPE:
            [manager setResponseSerializer:[AFCompoundResponseSerializer serializer]];
            break;
            
        default:
            break;
    }
    
    responseType = type;
}

- (void)initGeneralConfig:(NSMutableURLRequest *)urlRequest operation:(AFHTTPRequestOperation *)opearation type:(RESPONSE_TYPE)type
{
    opearation.securityPolicy.allowInvalidCertificates = bAllowInvalidCertificates;
    
    switch (type) {
        case JSON_RESPONSE_TYPE:
            [opearation setResponseSerializer:[AFJSONResponseSerializer serializer]];
            break;
            
        case XML_RESPONSE_TYPE:
            [opearation setResponseSerializer:[AFXMLParserResponseSerializer serializer]];
            break;
            
        case PROPERTYLIST_RESPONSE_TYPE:
            [opearation setResponseSerializer:[AFPropertyListResponseSerializer serializer]];
            break;
            
        case IMAGE_RESPONSE_TYPE:
            [opearation setResponseSerializer:[AFImageResponseSerializer serializer]];
            break;
            
        case COMPOUND_RESPONSE_TYPE:
            [opearation setResponseSerializer:[AFCompoundResponseSerializer serializer]];
            break;
            
        default:
            break;
    }
}

- (AFHTTPRequestOperation *)sendRequestWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                      responseType:(RESPONSE_TYPE)type
                                           success:(void (^)(AFHTTPRequestOperation *, id))success
                                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
    AFHTTPRequestOperation *operation = nil;
    
    if(!params || params.count == 0){
        operation = [manager HTTPRequestOperationWithRequest:urlRequest success:success failure:failure];
        [operationQueue addOperation:operation];
    }
    else{
        operation =[manager POST:request
                      parameters:params
                         success:success
                         failure:failure];
    }
    
    [self initGeneralConfig:((NSMutableURLRequest *) operation.request) operation:operation type:type];
    
    return operation;
}

- (AFHTTPRequestOperation *)sendGetRequestWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                      responseType:(RESPONSE_TYPE)type
                                           success:(void (^)(AFHTTPRequestOperation *, id))success
                                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
    AFHTTPRequestOperation *operation = nil;
    
    operation =[manager GET:request
                 parameters:params
                    success:success
                    failure:failure];
    [self initGeneralConfig:urlRequest operation:operation type:type];
    
    return operation;
}

- (AFHTTPRequestOperation *)sendPostRequestWithRequest:(NSString *)request
                                           Parameters:(id)params
                                         responseType:(RESPONSE_TYPE)type
                                              success:(void (^)(AFHTTPRequestOperation *, id))success
                                              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request]];
    AFHTTPRequestOperation *operation = nil;
    operation =[manager POST:request
                  parameters:params
                     success:success
                     failure:failure];
    [self initGeneralConfig:(NSMutableURLRequest *)operation.request operation:operation type:type];
    
    return operation;
}

- (AFHTTPRequestOperation *)uploadJSONFormDataWithRequest:(NSString *)request
                                              JSONParames:(NSDictionary *)jsonParams
                                            JSONFieldName:(NSString *)fieldName
                                               Parameters:(NSDictionary *)params
                                             responseType:(RESPONSE_TYPE)type
                                                  success:(void (^)(AFHTTPRequestOperation *, id))success
                                                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperation * uploadOperation = [manager POST:request
                                                  parameters:params
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
    {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonParams options:NSJSONWritingPrettyPrinted error:nil];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        [formData appendPartWithFormData:tempJsonData name:fieldName];
    }
                                                     success:success
                                                     failure:failure];
    
    [self initGeneralConfig:(NSMutableURLRequest *)uploadOperation.request operation:uploadOperation type:type];
    
    return uploadOperation;
}

- (AFHTTPRequestOperation *)uploadImageWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                          filePath:(NSString *)sfilePath
                                      responseType:(RESPONSE_TYPE)type
                                     fileFieldName:(NSString *)filedName
                                           success:(void (^)(AFHTTPRequestOperation *, id))success
                                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperation * uploadOperation = [manager POST:request
                                                  parameters:params
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                                {
                                                   [formData appendPartWithFileURL:[NSURL fileURLWithPath:sfilePath] name:filedName error:nil];
                                                }
                                                     success:success
                                                     failure:failure];
    
    [self initGeneralConfig:(NSMutableURLRequest *)uploadOperation.request operation:uploadOperation type:type];
    
    return uploadOperation;
}

- (AFHTTPRequestOperation *)uploadImageWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                          fileData:(NSString *)fileData
                                      responseType:(RESPONSE_TYPE)type
                                     fileFieldName:(NSString *)filedName
                                           success:(void (^)(AFHTTPRequestOperation *, id))success
                                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure
{
    AFHTTPRequestOperation * uploadOperation = [manager POST:request
                                                  parameters:params
                                   constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                                                {
                                                    [formData appendPartWithFileURL:[NSURL fileURLWithPath:fileData] name:filedName error:nil];
//                                                    [formData appendPartWithFormData:fileData name:filedName];
                                                }
                                                     success:success
                                                     failure:failure];
    
    [self initGeneralConfig:(NSMutableURLRequest *)uploadOperation.request operation:uploadOperation type:type];
    
    return uploadOperation;
}

- (void)setFTimeoutInterval:(float)_fTimeoutInterval{
    fTimeoutInterval = _fTimeoutInterval;
}

- (void)setBAllowInvalidCertificates:(BOOL)_bAllowInvalidCertificates{
    bAllowInvalidCertificates = _bAllowInvalidCertificates;
}

- (void)setNetworkStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus))_block{
    [manager.reachabilityManager setReachabilityStatusChangeBlock:_block];
    
//    ^(AFNetworkReachabilityStatus status) {
//        switch (status) {
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                [operationQueue setSuspended:NO];
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//            default:
//                [operationQueue setSuspended:YES];
//                break;
//        }
    
}

#pragma mark 提醒框相关
- (void)activityIndicate:(BOOL)isBegin tipContent:(NSString *)content MBProgressHUD:(MBProgressHUD *)hudd target:(UIView *)target displayInterval:(float)interval
{
    if ([NSThread isMainThread])
    {
        [self onDisplayMBProcessHUD:isBegin tipContent:content MBProgressHUD:hudd target:target displayInterval:interval];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onDisplayMBProcessHUD:isBegin tipContent:content MBProgressHUD:hudd target:target displayInterval:interval];
        });
    }
}

- (void)onDisplayMBProcessHUD:(BOOL)isBegin tipContent:(NSString *)content MBProgressHUD:(MBProgressHUD *)hudd target:(UIView *)target displayInterval:(float)interval
{
    [hud setHidden:NO];
    [hud setOpaque:YES];
    
    if(isBegin){
        if(hud == nil ){
            hud = [MBProgressHUD showHUDAddedTo:target animated:YES];
        }
        if(hud.bNeedHidden && hud){
            [hud hide:YES];
            hud = nil;
            hud = [MBProgressHUD showHUDAddedTo:target animated:YES];
        }
        
        [target setUserInteractionEnabled:NO];
        if(target == nil){
            [[[UIApplication sharedApplication] keyWindow].rootViewController.view setUserInteractionEnabled:NO];
        }
        
        hud.animationType = MBProgressHUDAnimationZoomOut;
        hud.detailsLabelText = content;
        hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
        hud.mode = MBProgressHUDModeIndeterminate;
        [target bringSubviewToFront:hud];
    }
    else {
        if(hud == nil && content.length > 0 && content){
            hud = [MBProgressHUD showHUDAddedTo:target animated:YES];
        }
        
        [target setUserInteractionEnabled:YES];
        if(target == nil){
            [[[UIApplication sharedApplication] keyWindow].rootViewController.view setUserInteractionEnabled:YES];
        }
        
        if(content == nil){
            [hud hide:YES];
            hud = nil;
        }
        else{
            hud.mode = 	MBProgressHUDModeText;
            hud.animationType = MBProgressHUDAnimationZoomOut;
            [hud setUserInteractionEnabled:NO];
            hud.detailsLabelText = content;
            hud.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
            hud.bNeedHidden = YES;
            [self performSelector:@selector(hiddenHud) withObject:nil afterDelay:interval];
        }
    }
}

- (void) hiddenHud{
    if(hud.bNeedHidden){
        [hud hide:YES];
        hud = nil;
    }
}



@end























