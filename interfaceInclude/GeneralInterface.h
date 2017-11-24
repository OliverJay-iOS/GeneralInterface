//
//  GeneralInterface.h
//  GeneralInterface
//
//  Created by mac  on 14-8-13.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../GeneralInterface/AFNetworking/AFNetworking.h"
#import "ShareHeader.h"
#import "DebugViewCtrl.h"
#import "NSObject+InitProperties.h"
#import "../GeneralInterface/uikit/UIKit+custom_.h"
#import "../GeneralInterface/uikit/CustomAlertViewManager.h"
#import "../GeneralInterface/uikit/GeneralTableViewCell.h"
#import "CoreDataInterface.h"
#import "APIKey.h"
#import "../GeneralInterface/uikit/FlatDatePicker.h"
#import "../GeneralInterface/AFNetworking/UIImageView+AFNetworking.h"
#import "../GeneralInterface/autonaviMap/Models/POIAnnotation.h"
#import "../GeneralInterface/js+object-c/ApexJs.h"
#import "../GeneralInterface/uikit/CustomAlertView.h"
//#import "../GeneralInterface/share/UMSocial_Sdk_3.3.8/Header/UMSocial.h"
//#import "../GeneralInterface/share/UMSocial_Sdk_Extra_Frameworks/UMSocial_ScreenShot_Sdk/UMSocialScreenShoter.h"
#include <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
//#import "../GeneralInterface/share/UMSocial_Sdk_3.3.8/Header/UMSocialControllerService.h"
#import "MobClick.h"
#import "../GeneralInterface/uikit/MYIntroductionPanel.h"
#import "../GeneralInterface/uikit/CustomIntroductionView.h"


@interface GeneralInterface : NSObject{
    @public
    void (^ NetChangeBlock)(AFNetworkReachabilityStatus status);
    MBProgressHUD * hud;
}

@property (nonatomic , readonly) AFHTTPRequestOperationManager * manager;
@property (nonatomic , readonly) NSOperationQueue *operationQueue;
@property (nonatomic , assign) BOOL bAllowInvalidCertificates;             //是否允许跳过 客户端信作服务器步骤
@property (nonatomic , assign) float fTimeoutInterval;                     //超时时间。默认10s
@property (nonatomic , assign) RESPONSE_TYPE responseType;                 //返回数据的类型；如xml、json、image等

+ (GeneralInterface *)Instance;

#pragma mark 网络请求相关

/*
   request:请求的字符串
   params: post传递的数据体；
   type:response数据的解析方式；如传0,则用默认的json解析方式
   success:请求成功返回的回调
   failure:请求失败返回的回调
 
 注：只在这个接口中，如为nil，则用默认的NSURLConnection方式去发出request，未指定httpMethod;
     如有值，则用post发出请求；
     在下面的接口中，params传nil或count为0,将不会设置到请求的httpbody中
 */
- (AFHTTPRequestOperation *)sendRequestWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                      responseType:(RESPONSE_TYPE)type
                                           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/*
 用get方法请求数据
 参数同上
 */
- (AFHTTPRequestOperation *)sendGetRequestWithRequest:(NSString *)request
                                           Parameters:(NSDictionary *)params
                                         responseType:(RESPONSE_TYPE)type
                                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/*
 用post方法请求数据
 参数同上
 */
- (AFHTTPRequestOperation *)sendPostRequestWithRequest:(NSString *)request
                                           Parameters:(id)params
                                         responseType:(RESPONSE_TYPE)type
                                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/*
 上传json数据。适用于body中有的字段不用json数据体，而有的字段需要用json格式的情况
 
 request:请求的字符串
 jsonParams:要求为json格式的字典
 fieldName:json字段值
 params: post传递的数据体；
 type:response数据的解析方式；如传0,则用默认的全局的responseType
 success:请求成功返回的回调
 failure:请求失败返回的回调
 */
- (AFHTTPRequestOperation *)uploadJSONFormDataWithRequest:(NSString *)request
                                              JSONParames:(NSDictionary *)jsonParams
                                            JSONFieldName:(NSString *)fieldName
                                               Parameters:(NSDictionary *)params
                                            responseType:(RESPONSE_TYPE)type
                                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/*
 上传json数据。适用于body中所有字段都用json格式的情况
 
 request:请求的字符串
 jsonParams:要求为json格式的字典
 type:response数据的解析方式；如传0,则用默认的全局的responseType
 success:请求成功返回的回调
 failure:请求失败返回的回调
 */
- (AFHTTPRequestOperation *)uploadJSONFormDataWithRequest:(NSString *)request
                                              JSONParames:(NSDictionary *)jsonParams
                                             responseType:(RESPONSE_TYPE)type
                                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/*
  上传图片
 params: post传递的数据体；
 fileData: 文件数据
 */
- (AFHTTPRequestOperation *)uploadImageWithRequest:(NSString *)request
                                        Parameters:(NSDictionary *)params
                                          fileData:(NSString *)fileData
                                      responseType:(RESPONSE_TYPE)type
                                     fileFieldName:(NSString *)filedName
                                           success:(void (^)(AFHTTPRequestOperation *, id))success
                                           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure;

- (void)setNetworkStatusChangeBlock:(void (^)(AFNetworkReachabilityStatus status))block;


#pragma mark 提示相关
/*
 有两种提醒状态:
 如果isBegin为真，则处于正在请求状态，此时interval不起作用,提示框将在请求完成时自动消失
 如果isBegin为假，则处于正在提醒状态，此时interval起作用,提示框过了interval后消失
 */
- (void)activityIndicate:(BOOL)isBegin tipContent:(NSString *)content MBProgressHUD:(MBProgressHUD *)hudd target:(UIView *)target displayInterval:(float)interval ;

#pragma mark VLog相关
- (void)onConfigurateLog:(BOOL)bShowDebugPage showLogView:(BOOL)bShowLogView;


@end






















