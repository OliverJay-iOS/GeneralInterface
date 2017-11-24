//
//  DebugViewCtrl.h
//  DebugTool
//
//  Created by mac  on 14-8-9.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>


//namespace debugTool {
//    static void printCallBack(char * ch , char * tag);
//}


@interface DebugViewCtrl : UIViewController<UITextFieldDelegate,UIGestureRecognizerDelegate,UITextViewDelegate>{
    @public
    IBOutlet UIScrollView * mainScorllView;
    IBOutlet UILabel * debugLabel;
    IBOutlet UISwitch * debugSwitch;
    IBOutlet UIButton * reportButton;
    IBOutlet UILabel * domainLabel;
    IBOutlet UITextField * domainField;
    IBOutlet UIButton * parseDomainButton;
    IBOutlet UITextView * parseDomainResultTextView;
    IBOutlet UIButton * pingButton;
    IBOutlet UITextField * pingField;
    IBOutlet UITextView * pingResultView;
    IBOutlet UILabel * detailLabel;
    IBOutlet UITextView * detailTextView;
    
    UIView * logView;
    UITextView * logTextView;
    UIButton * closeLogButton;
}

+ (DebugViewCtrl *)instance;

- (BOOL)beginDebug:(UIViewController *)sourceObject completionBlock:(void (^)(void))completionBlock domainChangeBlock:(void (^) (NSString * newDomainValue)) domainChangeBlock;

- (BOOL)endDebug;

- (BOOL)initLogFunction;

- (BOOL)onHaveInitLog;

- (BOOL)onShowLogView:(BOOL)bShowLogView;


/*
 params:
 appName:app的名称
 deviceName:设备名称,如iPhone
 systemName:系统名称
 osVersion:系统版本
 deviceModel:设备型号
 localizedModel:本地区域名称
 appVersion:app的版本
 logPath:log文件的路径
 domainName:当前app的域名
 */
- (void)onOpenDebugToolWithAppName:(NSString *)appName
                             deviceName:(NSString *)deviceName
                             systemName:(NSString *)systemName
                          osVersion:(NSString *)osVersion
                            deviceModel:(NSString *)deviceModel
                         localizedModel:(NSString *)localizedModel
                             appVersion:(NSString *)appVersion
                                logPath:(NSString *)logPath
                             domainName:(NSString *)domainName;

@end








