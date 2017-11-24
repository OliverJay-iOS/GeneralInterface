//
//  PublicMethod.m
//  PhoneOpenAccountTest
//
//  Created by mac  on 14-3-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "PublicMethod.h"
#import <CommonCrypto/CommonDigest.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <mach/mach_init.h>
#import <mach/mach_host.h>
#import "UIKit+custom_.h"
#import "UIKit+custom_.h"
#import "TTTAttributedLabel.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <mach/mach.h>
#include <netinet/in.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "../pingDomain/IPPingManager.h"
#import "axAes.h"
#include <netdb.h>
#import <AddressBook/AddressBook.h>
//#include <stdio.h>
//#include <stdlib.h>

//#import "CustomTestField.h"


@implementation PublicMethod


//把数组转换为字符串。
+ (NSString *)convertArrayToString:(NSArray *)array{
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    for( NSInteger i=0;i<[array count];i++ ){
        [string appendFormat:@"%@%@",(NSString *)array[i], (i<([array count]-1))?@",":@""];
    }
    return string;
}

//将url的传入参数截取出来
+ (NSArray *)convertURLToArray:(NSString *)string{
    if([string rangeOfString:@"?"].length != 0){
        int i = [string rangeOfString:@"?"].location;
        NSString *newString = [string substringFromIndex:i+1];
        return [newString componentsSeparatedByString:@"&"];
    }
    else{
        return  nil;
    }
}

//将?后面的字符串截掉
+ (NSURL *)suburlString:(NSURL *)urlString{
    return [NSURL URLWithString: [urlString.absoluteString substringToIndex:[urlString.absoluteString rangeOfString:@"?"].location]];
}

//把字符串转换为数组。
+ (NSArray *)convertStringToArray:(NSString *)string{
    return [string componentsSeparatedByString:@","];
}

//匹配是否为email地址。
+ (BOOL)validateEmail:(NSString *)candidate{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}

+ (BOOL)validateCellPhone:(NSString *)candidate{
    if (candidate.length < 11) {
        return NO;
    }
    
    NSString *phoneRegex = @"(^[1][3,5,8][0-9]{9}$)|(^[1][4][7][0-9]{8}$)|(^[1][7][7][0-9]{8}$)";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:candidate];
}

//获取文件的大小。
+ (long)getDocumentSize:(NSString *)documentsDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = paths[0];
//    documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat: @"/%@/", folderName]];
    //    NSDictionary *fileAttributes = [fileManager attributesOfFileSystemForPath:documentsDirectory error:nil];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:documentsDirectory error:nil];
    
    long size = 0;
    if(fileAttributes != nil)
    {
        NSNumber *fileSize = fileAttributes[NSFileSize];
        size = [fileSize longValue];
    }
    return size;
}

//得到小写字母。
+ (NSArray *)getLetters
{
    return @[@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z"];
}

//得到大写字母
+ (NSArray *)getUpperLetters
{
    return @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z"];
}

//得到ip地址。
+ (NSString *)getIPAddress
{
    NSString *address = @"Unknown";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                //                address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                //                NSLog(@"address: %@", [NSString stringWithUTF8String:temp_addr->ifa_name]);
                if([@(temp_addr->ifa_name) isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

//得到空闲的内存。
+ (NSString *)getFreeMemory{
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    //  natural_t mem_total = mem_used + mem_free;
    return [NSString stringWithFormat:@"%0.1f MB used/%0.1f MB free", mem_used/1048576.f, mem_free/1048576.f];
    //    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}

//获取硬盘空闲的空间。
+ (NSString *)getDiskUsed
{
    NSDictionary *fsAttr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    float diskSize = [fsAttr[NSFileSystemSize] doubleValue] / 1073741824.f;
    float diskFreeSize = [fsAttr[NSFileSystemFreeSize] doubleValue] / 1073741824.f;
    float diskUsedSize = diskSize - diskFreeSize;
    return [NSString stringWithFormat:@"%0.1f GB of %0.1f GB", diskUsedSize, diskSize];
}

+ (NSString *)getStringValue:(id)value
{
    if ([value isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        if ([@"" isEqualToString:value]) {
            return nil;
        }
        return value;
    }
    else
    {
        return [value stringValue];
    }
}

//创建某个路径是否成功。
+ (BOOL)createDirectorysAtPath:(NSString *)path{
    @synchronized(self){
        NSFileManager* manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:path]) {
            NSError *error = nil;
            if (![manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error]) {
                return NO;
            }
        }
    }
    return YES;
}

//获取文件路径。
+ (NSString*)getDirectoryPathByFilePath:(NSString *)filepath{
    if(!filepath || [filepath length] == 0){
        return @"";
    }
    
    int pathLength = [filepath length];
    int fileLength = [[filepath lastPathComponent] length];
    return [filepath substringToIndex:(pathLength - fileLength - 1)];
}

+ (NSString *)getFilePath:(CACHE_PATH_TYPE)type fileName:(NSString *)fileName{
    NSString *totalPath=nil;
    switch (type) {
        case DOCUMENT_CACHE:
        {
            NSArray* ar = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            totalPath = [[ar objectAtIndex:0]stringByAppendingPathComponent:fileName];
        }
            break ;
        case CACHESDIRECTORY:
        {
            NSArray* ar = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            totalPath = [[ar lastObject] stringByAppendingPathComponent:fileName];
        }
            break ;
    }
    return totalPath;
    
}

+ (UIFont *) GetSysFont
{
	return [UIFont systemFontOfSize:20];
}

+ (UIFont *) GetIndexBarFont
{
	return [UIFont boldSystemFontOfSize:12];
}

+ (int) GetSysFontHeight
{
	UIFont *font = [PublicMethod GetSysFont];
    
	NSLog(@"xHeight capHeight =%f,%f",font.xHeight,font.capHeight);
    
	return font.xHeight + font.capHeight;
}

+ (NSString *)GetImageIdentify{
    CFUUIDRef theUUID=CFUUIDCreate(NULL);
    CFStringRef str=CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
//    __autoreleasing NSString * identifyString =(__bridge NSString*)str;
    return  (__bridge_transfer NSString*)str;
}

+ (NSString *)MD5:(NSString *)srcString{
    const char *cStr = [srcString UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    NSString *md5Result = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return md5Result;
}

+ (UIView *)getSepratorLine:(CGRect )rect alpha:(CGFloat)alpha{
    __autoreleasing UIView *subView=[[UIView alloc]initWithFrame:rect];
    [subView setBackgroundColor:[UIColor colorWithWhite:0.6 alpha:alpha]];
    return subView;
}

+ (void) trimText:(NSString **)srcString{
//    *srcString = [*srcString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
}

+ (float) getWidth:(UIFont *)font{
    return font.leading;
}

+ (float) getStringWidth:(NSString *)str font:(UIFont *)font{
    CGSize size=[(str?str: @"") sizeWithFont:font constrainedToSize:CGSizeMake(320, 9999)
                               lineBreakMode:NSLineBreakByWordWrapping];
    return size.width;
}

+ (float) getStringHeight:(NSString *)str font:(UIFont *)font{
    CGSize size=[(str?str: @"") sizeWithFont:font constrainedToSize:CGSizeMake(320, 9999)
                               lineBreakMode:NSLineBreakByWordWrapping];
    return size.height;
}

+ (CGSize) getStringSize:(NSString *)str font:(UIFont *)font{
    CGSize size=[(str?str: @"") sizeWithFont:font constrainedToSize:CGSizeMake(320, 9999)
                               lineBreakMode:NSLineBreakByWordWrapping];
    return size;
}

+ (UIButton *) InitReadXY:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target{
    //生成数字证书申请责任书/协议书
    UIButton * requestZRS = [[UIButton alloc]initWithFrame:frame];
    [requestZRS setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    UIButton * markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [markButton setFrame:CGRectMake(7, 7, ButtonHeight - 7*2, ButtonHeight - 7*2)];
    [markButton setBackgroundImage:[UIImage imageNamed:@"checkbox_default"] forState:UIControlStateNormal];
    [markButton setBackgroundImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateHighlighted];
    [markButton addTarget: target action: @selector(onButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    [markButton setUserInteractionEnabled:YES];
    [requestZRS addSubview:markButton];
    
    requestZRS.tag = tag;
    [requestZRS addTarget: target action: @selector(onButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    [requestZRS setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [requestZRS setTitleEdgeInsets:UIEdgeInsetsMake(0, ButtonHeight - 7+5, 0, 0)];
    [requestZRS setTitle:title forState:UIControlStateNormal];
    requestZRS.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [requestZRS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    return requestZRS;
}

+ (UIButton *) InitReadXYWithAttributeLabel:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target options:(NSArray *)options superView:(UIView *)superView{
    //生成数字证书申请责任书/协议书
    UIButton * requestZRS = [[UIButton alloc]initWithFrame:frame];
    [requestZRS setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    
    UIButton * markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [markButton setFrame:CGRectMake(7, 7, ButtonHeight - 7*2, ButtonHeight - 7*2)];
    [markButton setBackgroundImage:[UIImage imageNamed:@"checkBox_default"] forState:UIControlStateNormal];
    [markButton setBackgroundImage:[UIImage imageNamed:@"checkBox_active"] forState:UIControlStateHighlighted];
    [markButton addTarget: target action: @selector(onButtonClick:) forControlEvents: UIControlEventTouchUpInside];
    [markButton setUserInteractionEnabled:YES];
    [requestZRS addSubview:markButton];
    
    TTTAttributedLabel *la=[[TTTAttributedLabel alloc]initWithFrame: CGRectMake(ButtonHeight, 0, frame.size.width - ButtonHeight , frame.size.height)];
    la.font = TipFont;
    la.textColor = [UIColor darkGrayColor];
    la.lineBreakMode = NSLineBreakByWordWrapping;
    la.numberOfLines = 0;
    la.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    
    la.highlightedTextColor = [UIColor whiteColor];
    la.shadowColor = [UIColor colorWithWhite:0.87 alpha:1.0];
    la.shadowOffset = CGSizeMake(0.0f, 1.0f);
    la.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    
    NSMutableArray * underlineTexts = [NSMutableArray array];
    NSMutableArray * underlineRanges = [NSMutableArray array];
    [la setText:title afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSMutableString * sMessage = [NSMutableString stringWithString:[mutableAttributedString string]];
        NSRange range =[sMessage rangeOfString:@"<<"] ;
        NSString * subString = nil;
        while (range.location != NSNotFound) {
//            NSLog(@"options:NSForcedOrderingSearch].location =%@",NSStringFromRange([sMessage rangeOfString:@">>" options:NSForcedOrderingSearch]));
            int length = [sMessage rangeOfString:@">>" options:NSForcedOrderingSearch].location - range.location - 2;
            range = NSMakeRange(range.location + 2, length);
            subString = [sMessage substringWithRange:range];
            [sMessage deleteCharactersInRange:NSMakeRange(0, range.location + range.length + 2)];
//            NSLog(@"subString =%@,%@",subString,NSStringFromRange(range));
            [underlineTexts addObject:subString];
            
            range =[sMessage rangeOfString:@"<<"] ;
        }
        
        NSRange preRange = NSMakeRange(0, [mutableAttributedString string].length);
        for (NSString * text in underlineTexts) {
            range = [[mutableAttributedString string] rangeOfString:text options:NSCaseInsensitiveSearch range:preRange];
            
            UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:17];
            CTFontRef italicFont = CTFontCreateWithName((CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
            
            if (italicFont) {
                [mutableAttributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:range];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:range];
                CFRelease(italicFont);
                
                [mutableAttributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[ButtonColorNormal_Wu CGColor] range:range];
                [underlineRanges addObject:NSStringFromRange(range)];
            }
            
            preRange = NSMakeRange(range.location + range.length, [mutableAttributedString string].length - range.location - range.length);
        }
        
        return mutableAttributedString;
    }];
    
    for (int i =0 ;i < underlineRanges.count;i++) {
        [la addLinkToURL:[NSURL URLWithString:[options objectAtIndex:i]] withRange:NSRangeFromString([underlineRanges objectAtIndex:i])];
    }
    
    la.delegate = target;
    [requestZRS addSubview:la];
    [superView addSubview:requestZRS];
    
    return requestZRS;
}

+ (UIButton *) CreateButton:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target{
    UIButton * btn = [[UIButton alloc]initWithFrame:frame];
//    [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [btn setBackgroundColor:buttonColor];
    [btn setBackgroundColor:BTN_DEFAULT_REDBG_COLOR];
    
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:TITLE_WHITE_COLOR forState:UIControlStateNormal];
    [btn setTitleColor:WARN_TITLE_COLOR forState:UIControlStateHighlighted];
    [target addSubview:btn];
    
    return btn;
}

+ (UITextField *) CreateField:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target{
//    CustomTestField * phoneEditor = [[CustomTestField alloc] initWithFrame: frame];
    UITextField * phoneEditor = [[UITextField alloc]initWithFrame:frame];
	phoneEditor.backgroundColor = [UIColor clearColor];
    phoneEditor.tag = tag;
	phoneEditor.borderStyle = UITextBorderStyleNone;
//    [phoneEditor setBackground:[[UIImage imageNamed:@"bg_editText_normal"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ]];
    phoneEditor.layer.borderColor = TEXTFEILD_BOLD_DEFAULT_COLOR.CGColor;
    phoneEditor.layer.cornerRadius = 2;
    phoneEditor.layer.masksToBounds = YES;
    phoneEditor.layer.borderWidth = 1;
	phoneEditor.keyboardType = UIKeyboardTypeNumberPad;
    phoneEditor.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneEditor.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [phoneEditor setTextAlignment:NSTextAlignmentLeft];
	[phoneEditor setFont: FieldFont];
    [phoneEditor setPlaceholder:title];
	[phoneEditor setTextColor: FieldFontColor];
    [target addSubview:phoneEditor];
    
    return phoneEditor;
}

+ (void)publicCornerBorderStyle:(UIView *)view{
    view.layer.borderColor = TEXTFEILD_BOLD_DEFAULT_COLOR.CGColor;
    view.layer.cornerRadius = 2;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0.6;
}

+ (UIControl *) CreateControl:(CGRect)frame tag:(int)tag target:(id)target{
    UIControl * centerView = [[UIControl alloc]initWithFrame:frame];
    centerView.tag = tag;
    [target addSubview:centerView];
    return centerView;
}

//生成选择框。如风险评测中的。
+ (UIButton *) InitSelectTitle:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target{
    UIButton * requestZRS = [[UIButton alloc]initWithFrame:frame];
    [requestZRS setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [requestZRS setBackgroundColor:[UIColor clearColor]];
    
    UIButton * markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [markButton setFrame:CGRectMake(0, frame.size.height/2-30/2 -2 , 30, 30)];
    [markButton setBackgroundImage:[UIImage imageNamed:@"radio_default"] forState:UIControlStateNormal];
    
    [markButton setUserInteractionEnabled:NO];
    [requestZRS addSubview:markButton];
    
    requestZRS.tag = tag;
//    [requestZRS addTarget: target action: @selector(onSelectClick:) forControlEvents: UIControlEventTouchDown];
    [requestZRS setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [requestZRS setTitleEdgeInsets:UIEdgeInsetsMake(0, 30+3, 0, 0)];
    [requestZRS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [requestZRS setTitle:title forState:UIControlStateNormal];
    
    return requestZRS;
}

//生成多选选择框。如风险评测中的。
+ (UIButton *) InitDoubleSelectTitle:(NSString *)title withFrame:(CGRect)frame tag:(int)tag target:(id)target{
    UIButton * requestZRS = [[UIButton alloc]initWithFrame:frame];
    [requestZRS setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [requestZRS setBackgroundColor:[UIColor clearColor]];
    
    UIButton * markButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [markButton setFrame:CGRectMake(0, frame.size.height/2-30/2 , 30, 30)];
    [markButton setBackgroundImage:[UIImage imageNamed:@"checkBox_default"] forState:UIControlStateNormal];
    [markButton setUserInteractionEnabled:NO];
    [requestZRS addSubview:markButton];
    
    requestZRS.tag = tag;
    //    [requestZRS addTarget: target action: @selector(onSelectClick:) forControlEvents: UIControlEventTouchDown];
    [requestZRS setTitleColor:GrayTipColor_Wu forState:UIControlStateNormal];
    [requestZRS setTitleEdgeInsets:UIEdgeInsetsMake(0, 30+3, 0, 0)];
    [requestZRS setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [requestZRS setTitle:title forState:UIControlStateNormal];
    
    return requestZRS;
}


+ (UILabel *) initLabelWithFrame:(CGRect)frame title:(NSString *)title target:(id)target{
//    CGRectMake(levelSpace, 0, screenWidth - levelSpace, labelHeight)
//    @"请您完成以下风险评测表";
    UILabel *la=[[UILabel alloc]initWithFrame: frame];
	la.backgroundColor = [UIColor clearColor];
    [la setText:title];
	[la setFont: TipFont];
    la.textAlignment = NSTextAlignmentLeft;
	[la setTextColor: GrayTipColor_Wu];
    la.lineBreakMode = NSLineBreakByTruncatingTail;
    [target addSubview:la];
    return la;
}

//清理特殊字符
+ (void) trimSpecialCharacters:(NSString **)unFilterString{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"[,\\.`\"!@#$%^&*()_+|＊*]"
                                                                                options:0
                                                                                  error:NULL];
    [expression stringByReplacingMatchesInString:*unFilterString
                                                                   options:0
                                                                     range:NSMakeRange(0, (*unFilterString).length)
                                                              withTemplate:@""];
}

+ (void) saveToUserDefaults:(id) object key: (NSString *)key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
		[standardUserDefaults setObject:object forKey:key];
        [standardUserDefaults synchronize];
	}
}

+ (id) userDefaultsValueForKey:(NSString*) key
{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	if (standardUserDefaults) {
        return [standardUserDefaults objectForKey:key];
	}
    return nil;
}

+ (void) filterString:(NSString **)unfilteredString{
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEFxX"] invertedSet];
    *unfilteredString = [[*unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

+ (void) filterNumber:(NSString **)unfilteredString{
    NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    *unfilteredString = [[*unfilteredString componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
}

+ (NSData *) convertImageToCapacity:(UIImage *)image capacity:(int)capacity{
    @autoreleasepool {
        CGSize newSize=CGSizeMake(0, 0);
        
        CGFloat targetWid = image.size.width;
        CGFloat targetHei = image.size.height;
        int bit=1;
        
        if(targetWid > targetHei){
            while (targetWid > 300) {
                targetWid = image.size.width/++bit;
            }
            newSize.width = targetWid;
            newSize.height = image.size.height/bit;
        }
        else{
            while (targetHei > 300) {
                targetHei = image.size.height/++bit;
            }
            newSize.height = targetHei;
            newSize.width = image.size.width/bit;
        }
        
        UIImage * img = [image imageByResizingToSize:newSize];
        d_Data = UIImageJPEGRepresentation(img, 1);
        
//        [self CaculateImageKBs:img capacity:capacity];
    }
    return d_Data;
}

+ (BOOL) validateIdentityCard: (NSString *)sPaperId
{
//    BOOL flag;
//    if (identityCard.length <= 0) {
//        flag = NO;
//        return flag;
//    }
//    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
//    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
//    return [identityCardPredicate evaluateWithObject:identityCard];
    
    //判断位数
    if ([sPaperId length] != 15 && [sPaperId length] != 18) {
        return NO;
    }
    NSString *carid = sPaperId;
    long lSumQT =0;
    int R[] ={7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    unsigned char sChecker[11]={'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:sPaperId];
    
    if ([sPaperId length] == 15) {
        [mString insertString:@"19" atIndex:6];
        long p = 0;
        const char *pid = [mString UTF8String];
        for (int i=0; i<=16; i++)
        {
            p += (pid[i]-48) * R[i];
        }
        
        int o = p%11;
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        [mString insertString:string_content atIndex:[mString length]];
        carid = mString;
    }
    
    //判断地区码
    NSString * sProvince = [carid substringToIndex:2];
    if (![self areaCode:sProvince]) {
        return NO;
    }
    //判断年月日是否有效
    //年份
    int strYear = [[self getStringWithRange:carid Value1:6 Value2:4] intValue];
    
    //月份
    int strMonth = [[self getStringWithRange:carid Value1:10 Value2:2] intValue];
    
    //日
    int strDay = [[self getStringWithRange:carid Value1:12 Value2:2] intValue];
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [dateFormatter setTimeZone:localZone];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date=[dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    
    if (date == nil) {
        return NO;
    }
    
    const char *PaperId  = [carid UTF8String];
    
    //检验长度
    if( 18 != strlen(PaperId)) return -1;
    
    //校验数字
    for (int i=0; i<18; i++)
    {
        if ( !isdigit(PaperId[i]) && !(('X' == PaperId[i] || 'x' == PaperId[i]) && 17 == i) )
        {
            return NO;
        }
    }
    
    //验证最末的校验码
    for (int i=0; i<=16; i++)
    {
        lSumQT += (PaperId[i]-48) * R[i];
    }
    
    if (sChecker[lSumQT%11] != PaperId[17] )
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL) isAdultManByIdentifyCard:(NSString *)identifyCard{
    if(identifyCard.length > 15){
        int birthYear = [[identifyCard substringWithRange:NSMakeRange(6, 8) ] intValue];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"yyyyMMdd"];
        int age = [[dateFormatter stringFromDate:[NSDate date]]intValue] - birthYear ;
        NSLog(@"年龄 = %i,%i",age,birthYear);
        
        if (age >= 180000) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return YES;
    }
}

+ (BOOL) isCardValidByYXQ:(NSString *)yxqText{
    NSCharacterSet *Chars = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    yxqText = [[yxqText componentsSeparatedByCharactersInSet:Chars] componentsJoinedByString:@""];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    int nowTime = [[dateFormatter stringFromDate:[NSDate date]] intValue];
    NSLog(@"yxq noewtime= %@,%i",yxqText,nowTime);
    
    if([yxqText intValue] < nowTime){
        return NO;
    }
    else{
        return YES;
    }
}

+ (NSString *)getStringWithRange:(NSString *)str Value1:(NSInteger )value1 Value2:(NSInteger )value2
{
    return [str substringWithRange:NSMakeRange(value1,value2)];
}

+ (BOOL)areaCode:(NSString *)code
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:@"北京" forKey:@"11"];
    
    [dic setObject:@"天津" forKey:@"12"];
    
    [dic setObject:@"河北" forKey:@"13"];
    
    [dic setObject:@"山西" forKey:@"14"];
    
    [dic setObject:@"内蒙古" forKey:@"15"];
    
    [dic setObject:@"辽宁" forKey:@"21"];
    
    [dic setObject:@"吉林" forKey:@"22"];
    
    [dic setObject:@"黑龙江" forKey:@"23"];
    
    [dic setObject:@"上海" forKey:@"31"];
    
    [dic setObject:@"江苏" forKey:@"32"];
    
    [dic setObject:@"浙江" forKey:@"33"];
    
    [dic setObject:@"安徽" forKey:@"34"];
    
    [dic setObject:@"福建" forKey:@"35"];
    
    [dic setObject:@"江西" forKey:@"36"];
    
    [dic setObject:@"山东" forKey:@"37"];
    
    [dic setObject:@"河南" forKey:@"41"];
    
    [dic setObject:@"湖北" forKey:@"42"];
    
    [dic setObject:@"湖南" forKey:@"43"];
    
    [dic setObject:@"广东" forKey:@"44"];
    
    [dic setObject:@"广西" forKey:@"45"];
    
    [dic setObject:@"海南" forKey:@"46"];
    
    [dic setObject:@"重庆" forKey:@"50"];
    
    [dic setObject:@"四川" forKey:@"51"];
    
    [dic setObject:@"贵州" forKey:@"52"];
    
    [dic setObject:@"云南" forKey:@"53"];
    
    [dic setObject:@"西藏" forKey:@"54"];
    
    [dic setObject:@"陕西" forKey:@"61"];
    
    [dic setObject:@"甘肃" forKey:@"62"];
    
    [dic setObject:@"青海" forKey:@"63"];
    
    [dic setObject:@"宁夏" forKey:@"64"];
    
    [dic setObject:@"新疆" forKey:@"65"];
    
    [dic setObject:@"台湾" forKey:@"71"];
    
    [dic setObject:@"香港" forKey:@"81"];
    
    [dic setObject:@"澳门" forKey:@"82"];
    
    [dic setObject:@"国外" forKey:@"91"];
    
    if ([dic objectForKey:code] == nil) {
        return NO;
    }
    
    return YES;
}

static NSData * d_Data = nil;
+ (void) CaculateImageKBs:(UIImage *)image capacity:(int)capacity{
    CGFloat f=1;
    
    for(; f>0 && d_Data.length/1024>capacity ; f-=0.1){
        d_Data = nil;
        d_Data = UIImageJPEGRepresentation(image,f);
    }
    
    if(d_Data.length/1024>capacity){
        [self CaculateImageKBs:[UIImage imageWithData:d_Data] capacity:capacity] ;
    }
    else{
        return ;
    }
}

+ (NSData *) compressImage:(UIImage *)image{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 60*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

+ (void) hideGradientBackground:(UIView*)theView
{
    for (UIView * subview in theView.subviews)
    {
        if ([subview isKindOfClass:[UIImageView class]])
                subview.hidden = YES;
        
        [self hideGradientBackground:subview];
    }
}

+ (BOOL) fileManageCopyFileFromPath:(NSString *)fromPath toPath:(NSString *)toPath{
    NSError * error = nil;
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    [fileMgr removeItemAtPath:toPath error:&error];
    return [fileMgr copyItemAtPath:fromPath toPath:toPath error:&error];
//    return [fileMgr moveItemAtPath:fromPath toPath: toPath error: &error];
}

+ (void) redirectConsoleLogToDocumentFolder
{
//    NSLog(@"logcontent =%@",[NSString stringWithContentsOfFile:ConsoleLogPath encoding:NSUTF8StringEncoding error:nil]);
//    freopen([ConsoleLogPath fileSystemRepresentation],"a+",stderr);
}

+ (NSDictionary * ) getDeviceMessage{
    NSString * identify = [self GetMacAddress];
    //mac地址
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleName"];
    // 当前应用名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    //手机别名： 用户定义的名称
    NSString* deviceSystemName = [[UIDevice currentDevice] systemName];
    //系统名称
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    //手机系统版本
    NSString* phoneModel = [self getDeviceType];
    //手机型号 是iphone4还是iphone4s之类
    
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:identify,DEVICEID,
                                                      deviceSystemName,DEVICEVERSION,
                                                      [NSString stringWithFormat:@"%@/%@",phoneModel,[self getSysInfoByName:"hw.machine"]],DEVICEXH,
                                                      appCurName,APPNAME,
                                                      phoneVersion,OSVERSION,
                                                      appCurVersion,APPVERSION,
                                                      nil];
}

+ (NSString*) getDeviceType
{
    NSString *platform = [self getSysInfoByName:"hw.machine"];
    
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"]) {
        return @"iFPGA";
    }
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) {
        return @"iPhone2G";
    }
    else if ([platform isEqualToString:@"iPhone1,2"]) {
        return @"iPhone3G";
    }
    else if ([platform hasPrefix:@"iPhone2"]) {
        return @"iPhone3GS";
    }
    else if ([platform hasPrefix:@"iPhone3"]) {
        return @"iPhone4";
    }
    else if ([platform hasPrefix:@"iPhone4"]) {
        return @"iPhone4S";
    }
    else if ([platform isEqualToString:@"iPhone5,1"]
             || [platform isEqualToString:@"iPhone5,2"]) {
        return @"iPhone5";
    }
    else if ([platform isEqualToString:@"iPhone5,3"]
             || [platform isEqualToString:@"iPhone5,4"]) {
        return @"iPhone5C";
    }
    else if ([platform hasPrefix:@"iPhone6"]) {
        return @"iPhone5S";
    }
    
    // iPod
    else if ([platform hasPrefix:@"iPod1"]) {
        return @"iPod1";
    }
    else if ([platform hasPrefix:@"iPod2"]) {
        return @"iPod2";
    }
    else if ([platform hasPrefix:@"iPod3"]) {
        return @"iPod3";
    }
    else if ([platform hasPrefix:@"iPod4"]) {
        return @"iPod4";
    }
    else if ([platform hasPrefix:@"iPod5"]) {
        return @"iPod5";
    }
    
    // iPad
    if ([platform hasPrefix:@"iPad1"])  {
        return @"iPad1";
    }
    else if ([platform isEqualToString:@"iPad2,1"]
             || [platform isEqualToString:@"iPad2,2"]
             || [platform isEqualToString:@"iPad2,3"]
             || [platform isEqualToString:@"iPad2,4"]) {
        return @"iPad2";
    }
    else if ([platform isEqualToString:@"iPad3,1"]
             || [platform isEqualToString:@"iPad3,2"]
             || [platform isEqualToString:@"iPad3,3"]) {
        return @"iPad3";
    }
    else if ([platform isEqualToString:@"iPad3,4"]
             || [platform isEqualToString:@"iPad3,5"]
             || [platform isEqualToString:@"iPad3,6"]) {
        return @"iPad4";
    }
    else if ([platform isEqualToString:@"iPad4,1"]
             || [platform isEqualToString:@"iPad4,2"]) {
        return @"iPad Air";
    }
    
    // iPad mini
    else if ([platform isEqualToString:@"iPad2,5"]
             || [platform isEqualToString:@"iPad2,6"]
             || [platform isEqualToString:@"iPad2,7"]) {
        return @"iPad mini";
    }
    else if ([platform isEqualToString:@"iPad4,4"]
             || [platform isEqualToString:@"iPad4,5"]) {
        return @"iPad mini2";
    }
    
    // Apple TV
    else if ([platform hasPrefix:@"AppleTV2"]) {
        return @"Apple TV 2";
    }
    else if ([platform hasPrefix:@"AppleTV3"]) {
        return @"Apple TV 3";
    }
    
    else if ([platform hasPrefix:@"iPhone"]) {
        return @"Unknown iPhone";
    }
    else if ([platform hasPrefix:@"iPod"]) {
        return @"Unknown iPod";
    }
    else if ([platform hasPrefix:@"iPad"]) {
        return @"Unknown iPad";
    }
    else if ([platform hasPrefix:@"AppleTV"]) {
        return @"Unknown Apple TV";
    }
    
    // Simulator thanks Jordan Breeding
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
    {
        BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
        return smallerScreen ? @"Simulator iPhone" : @"Simulator iPad";
    }
    
    return @"Unknown Type";
}

+ (NSString *) getSysInfoByName:(char *)typeSpecifier
{
	size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = (char *)malloc(size);
	sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
	NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
	free(answer);
	return results;
}

+ (NSString*) GetMacAddress
{
    if([[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7){
        int mib[6];
        size_t len;
        char* buf;
        unsigned char* ptr;
        struct if_msghdr* ifm;
        struct sockaddr_dl* sdl;
        
        mib[0] = CTL_NET;
        mib[1] = AF_ROUTE;
        mib[2] = 0;
        mib[3] = AF_LINK;
        mib[4] = NET_RT_IFLIST;
        
        if ((mib[5] = if_nametoindex ("en0")) == 0)
        {
            return NULL;
        }
        
        if (sysctl (mib, 6, NULL, &len, NULL, 0) < 0)
        {
            return NULL;
        }
        
        if ((buf = new char[len]) == NULL)
        {
            return NULL;
        }
        
        if (sysctl (mib, 6, buf, &len, NULL, 0) < 0)
        {
            return NULL;
        }
        
        ifm = (struct if_msghdr *) buf;
        sdl = (struct sockaddr_dl *) (ifm + 1);
        ptr = (unsigned char *) LLADDR (sdl);
        NSString *outstring = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x",
                               *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
        delete[] buf;
        
        return [outstring uppercaseString];
    }
    else {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
}


const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;
+ (NSArray *)backtrace
{
    /*
     void* callstack[128];
     int frames = backtrace(callstack, 128);
     char **strs = backtrace_symbols(callstack, frames);
     
     int i;
     NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
     for (i = kSkipAddressCount;
     i < __min(kSkipAddressCount + kReportAddressCount, frames);
     ++i) {
     [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
     }
     free(strs);
     
     return backtrace;
     */
    
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = 0;i < frames;i++)
    {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    NSLog(@"backtrace =%@,%d",backtrace,frames);
    free(strs);
    
    return backtrace;
}

+ (NSString *)getOperationName{
    Class messageClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
	
	if (messageClass != nil) {
		// 获取运营商
		CTTelephonyNetworkInfo	*telInfo = [[CTTelephonyNetworkInfo alloc] init];
		NSString				*carrier = telInfo.subscriberCellularProvider.carrierName;
		
		return carrier;
	}
    
    return nil;
}

+ (NSInteger) getOPeratorType
{
    NSInteger type = 0;//非国内运行商或者找不到运行商信息或者无网络
    Class messageClass = (NSClassFromString(@"CTTelephonyNetworkInfo"));
    if(messageClass != nil)
    {
        CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
        CTCarrier * carrier = info.subscriberCellularProvider;
        NSInteger mobileCountryCode = [carrier.mobileCountryCode integerValue];
        NSInteger mobileNetworkCode = [carrier.mobileNetworkCode integerValue];
        if( mobileCountryCode == 460 && (mobileNetworkCode == 0 || mobileNetworkCode == 2 || mobileNetworkCode == 7))
        {
            type = NETTYPE_YIDONG;//移动
        }
        else if( mobileCountryCode == 460 && (mobileNetworkCode == 1 || mobileNetworkCode == 6))
        {
            type  = NETTYPE_LIANTONG;//联通
        }
        else if( mobileCountryCode == 460 && (mobileNetworkCode == 3 || mobileNetworkCode == 5 || mobileNetworkCode == 20))
        {
            type  = NETTYPE_DIANXIN;//电信
        }
    }
    return type;
}


//socket测速。需要ip和port
+ (void) doConnect:(serverItem *)item {
	@autoreleasepool {
        
//	CFSocketContext CTX = {0, self, NULL, NULL, NULL};
//	CFSocketRef _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketConnectCallBack, TCPServerConnectCallBack, &CTX);
//	if (NULL == _socket) {
//		NSLog(@"create socket failed!");
//		return;
//	}
        
        int sock = socket(AF_INET, SOCK_STREAM, 0);
        
        struct sockaddr_in addr4;
        memset(&addr4, 0, sizeof(addr4));
        addr4.sin_len = sizeof(addr4);
        addr4.sin_family = AF_INET;
        addr4.sin_port = htons([item->port intValue]);
        addr4.sin_addr.s_addr = inet_addr([item->ip UTF8String]);
        
//	CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addr4, sizeof(addr4));
//	NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init ];
//	[dateformatter setTimeStyle:NSDateFormatterFullStyle];
//	[dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
//	NSLog(@"date connect is %@",[dateformatter stringFromDate:[NSDate date]]);
        
        item->startTime = [NSDate date];
        if (-1 == connect(sock, (const struct sockaddr *)&addr4, sizeof(struct sockaddr_in))) {
            NSLog(@"error when connect");
            close(sock);
            item->startTime = nil;
            item->endTime = nil;
            return;
        }
        item->endTime = [NSDate date];
        
        close(sock);
        
        NSLog(@"startTime endTiem =%f,%f",[item->startTime timeIntervalSince1970],[item->endTime timeIntervalSince1970]);
    }
}

+ (NSString *)sha1:(NSString *)str {
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *)md5Hash:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    NSString *md5Result = [NSString stringWithFormat:
                           @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                           result[0], result[1], result[2], result[3],
                           result[4], result[5], result[6], result[7],
                           result[8], result[9], result[10], result[11],
                           result[12], result[13], result[14], result[15]
                           ];
    return md5Result;
}

+ (NSString *)onGetEncodeString:(NSString *)sourceString{
    return [AxAES Encode:sourceString];
}

+ (NSString *)onGetDecodeString:(NSString *)encodeString{
    return [AxAES Decode:encodeString];
}

+ (NSString *)trimSpaceAndNewLine:(NSString *)text{
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (int) onGetDaysInPreviousMonth{
    NSDate *date = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit) fromDate:date];
    NSInteger mouth = [dateComponents month];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:mouth - 1];
    NSRange range = [gregorian rangeOfUnit:NSDayCalendarUnit
                              inUnit:NSMonthCalendarUnit
                             forDate:[gregorian dateFromComponents:comps]];
    int daysInMonth = range.length;
    return daysInMonth;
}

//- (float)getWidthForHeaderString:(NSString *)text size:(CGSize)size font:(UIFont *)font{
//    return ceilf([text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping].width);
//}

+ (NSString *)onGetJSONStringWithDictionary:(NSDictionary *)dic{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = nil;
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }
    else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

+ (CGSize)makeSize:(CGSize)originalSize fitInSize:(CGSize)boxSize
{
    float widthScale = 0;
    float heightScale = 0;
    
    widthScale = boxSize.width/originalSize.width;
    heightScale = boxSize.height/originalSize.height;
    
    float scale = MIN(widthScale, heightScale);
    
    CGSize newSize = CGSizeMake(originalSize.width * scale, originalSize.height * scale);
    
    return newSize;
}

+ (NSMutableArray *)getUserContacts{
    NSMutableArray * userContacts = [NSMutableArray array];
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            ABAddressBookRef addressBook = ABAddressBookCreate();
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
        CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
        
        NSMutableDictionary * contact = [NSMutableDictionary dictionary];
        for(int i = 0; i < numberOfPeople; i++) {
            ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
            int32_t recordID = ABRecordGetRecordID(person);
            ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
            
            NSString *phoneNumber = @"";
            for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
                phoneNumber = (__bridge NSString *) (ABMultiValueCopyValueAtIndex(phoneNumbers, i));
            }
            
            [contact setObject:[lastName stringByAppendingString:firstName] forKey:@"contactName"];
            [contact setObject:phoneNumber forKey:@"contactNumber"];
            [userContacts addObject:contact];
        }
    }
    else {
        NSLog(@"no");
    }
    
    return  userContacts;
}

+ (void)removeFilePath:(NSString *)path{
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (UITableViewCell *)onGetTableViewCellBySubview:(UIView *)subview{
    UIView * superView = nil;
    while ((superView = subview.superview)) {
        NSLog(@"subview superview =%@,%@",subview,superView);
        if([superView isKindOfClass:[UITableViewCell class]]){
            break ;
        }
        else{
            subview = superView;
        }
    }
    
    return (UITableViewCell *)superView;
}

+ (void)deallocView:(UIView *)view{
#if !__has_feature(objc_arc)
    [view removeFromSuperview];
    [view release];
    view = nil;
#elif __has_feature(objc_arc)
    [view removeFromSuperview];
    view = nil;
#endif
}



@end










