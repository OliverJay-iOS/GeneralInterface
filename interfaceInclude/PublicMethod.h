//
//  PublicMethod.h
//  PhoneOpenAccountTest
//
//  Created by mac  on 14-3-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <runtime.h>
#import "ShareHeader.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LColor : NSObject
{
@public
	float m_red;
	float m_green;
	float m_blue;
	float m_alpha;
}

- (id)initWithColor:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

+ (LColor *)lightGrayColor;
+ (LColor *)darkGrayColor;
+ (LColor *)whiteColor;
+ (LColor *)yellowColor;

@end


@interface SJKHConfig : NSObject{
    
}

+ (UIFont *) GetSysFont;
+ (UIFont *) GetIndexBarFont;
+ (int) GetSysFontHeight;

@end



@interface PublicMethod : NSObject

//os 常用的公用方法。
+ (NSString *)convertArrayToString:(NSArray *)array;
+ (NSArray *)convertStringToArray:(NSString *)string;
+ (NSArray *)convertURLToArray:(NSString *)string;
+ (NSURL *)suburlString:(NSURL *)urlString;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validateCellPhone:(NSString *)candidate;

+ (void) saveToUserDefaults:(id) object key: (NSString *)key;
+ (id) userDefaultsValueForKey:(NSString*) key;

+ (NSString *)getNSStringFromCstring:(const char *)cString;

+ (long)getDocumentSize:(NSString *)folderName;
+ (NSArray *)getLetters;
+ (NSArray *)getUpperLetters;
+ (NSString *)getIPAddress;
+ (NSString *)getFreeMemory;
+ (NSString *)getDiskUsed;
+ (NSString *)getStringValue:(id)value;

+ (BOOL)createDirectorysAtPath:(NSString *)path;
+ (NSString*)getDirectoryPathByFilePath:(NSString *)filepath;

+ (NSString*)getFilePath :(CACHE_PATH_TYPE)type fileName:(NSString *)fileName;
+ (void) removeFilePath:(NSString *)path;

+ (NSString*) getDeviceType;

+ (NSString *)GetImageIdentify;

+ (NSString *)MD5:(NSString *)srcString;

+ (UIView *)getSepratorLine:(CGRect )rect alpha:(CGFloat)alpha;

+ (void) trimText:(NSString **)srcString;

+ (void) trimSpecialCharacters:(NSString **)unFilterString;

+ (float) getWidth:(UIFont *)font;

+ (float) getStringWidth:(NSString *)str font:(UIFont *)font;

+ (float) getStringHeight:(NSString *)str font:(UIFont *)font;

+ (CGSize) getStringSize:(NSString *)str font:(UIFont *)font;

+ (void) filterString:(NSString **)unfilteredString;

+ (void) filterNumber:(NSString **)unfilteredString;

//控件生成
+ (UIButton *) InitReadXY:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target;

//生成attribute字符
+ (UIButton *) InitReadXYWithAttributeLabel:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target options:(NSArray *)options superView:(UIView *)superView;

+ (UIButton *) InitSelectTitle:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target;

+ (UIButton *) InitDoubleSelectTitle:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target;

+ (UILabel *) initLabelWithFrame:(CGRect)frame title:(NSString *)title target:(id)target;

+ (UIButton *) CreateButton:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target;

+ (UIControl *) CreateControl:(CGRect)frame tag:(int)tag target:(id)target;

+ (UITextField *) CreateField:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target;

+ (void)publicCornerBorderStyle:(UIView *)view;

+ (NSData *) convertImageToCapacity:(UIImage *)image capacity:(int)capacity;

+ (NSData *) compressImage:(UIImage *)image;

//身份证验证
+ (BOOL) validateIdentityCard: (NSString *)identityCard;

//是否已满18岁
+ (BOOL) isAdultManByIdentifyCard:(NSString *)identifyCard;

//身份证有效期验证
+ (BOOL) isCardValidByYXQ:(NSString *)yxqText;

//隐藏webview的背景图
+ (void) hideGradientBackground:(UIView*)theView;

+ (BOOL) fileManageCopyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

+ (void) redirectConsoleLogToDocumentFolder;

+ (NSDictionary * ) getDeviceMessage;

+ (NSString*) GetMacAddress;

//崩溃时的堆栈
+ (NSArray *)backtrace;

+ (NSString *)sha1:(NSString *)str;

+ (NSString *)md5Hash:(NSString *)str;

+ (NSInteger ) getOPeratorType;

+ (NSString *) getOperationName;

+ (NSString *)onGetEncodeString:(NSString *)sourceString;

+ (NSString *)onGetDecodeString:(NSString *)encodeString;

+ (NSString *)trimSpaceAndNewLine:(NSString *)text;

+ (int) onGetDaysInPreviousMonth;

+ (NSString *)onGetJSONStringWithDictionary:(NSDictionary *)dic;

+ (CGSize)makeSize:(CGSize)originalSize fitInSize:(CGSize)boxSize;

//获取系统人列表
+ (NSMutableArray *)getUserContacts;

//获得subview的对应UITableViewCell
+ (UITableViewCell *)onGetTableViewCellBySubview:(UIView *)subview;

+ (void)deallocView:(UIView *)view;


@end











