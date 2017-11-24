//
//  ShareHeader.h
//  GeneralInterface
//
//  Created by mac  on 14-8-14.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#ifndef GeneralInterface_ShareHeader_h
#define GeneralInterface_ShareHeader_h

typedef enum
{
    DOCUMENT_CACHE                     = 0,
    CACHESDIRECTORY                    = 1
} CACHE_PATH_TYPE;

typedef enum{
    NETTYPE_YIDONG    = 1,//移动
    NETTYPE_LIANTONG  = 2,//联通
    NETTYPE_DIANXIN   = 3//电信
} NETTYPE;

typedef enum
{
    ZHIYE_DATA_TYPE                     = 22,
    XUELI_DATA_TYPE                     = 23,
    ZJYXQ_DATA_TYPE                     = 24
} SELECT_DATA_TYPE;

//网络数据返回类型，默认是json格式
typedef enum
{
    JSON_RESPONSE_TYPE                  = 1,
    XML_RESPONSE_TYPE                   = 2,
    PROPERTYLIST_RESPONSE_TYPE          = 3,
    IMAGE_RESPONSE_TYPE                 = 4,
    COMPOUND_RESPONSE_TYPE              = 5
} RESPONSE_TYPE;

#define COLOR_WITH_RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define BTN_DEFAULT_REDBG_COLOR COLOR_WITH_RGB(239,65,86)
#define PAGE_BG_COLOR COLOR_WITH_RGB(247,247,247)
#define TITLE_WHITE_COLOR COLOR_WITH_RGB(255,255,255)
#define WARN_TITLE_COLOR COLOR_WITH_RGB(121,121,121)
#define TEXTFEILD_BOLD_DEFAULT_COLOR COLOR_WITH_RGB(170,170,170)
#define GrayTipColor_Wu [UIColor colorWithRed:137.0/255 green:137.0/255 blue:137.0/255 alpha:1]
#define ButtonColorNormal_Wu [UIColor colorWithRed:33.0/255 green:163.0/255 blue:246.0/255 alpha:1]

#define FONT [UIFont systemFontOfSize:14]
#define TipFont [UIFont systemFontOfSize:16]
#define FieldFont [UIFont systemFontOfSize:16]
#define FieldFontColor [UIColor blackColor]
#define PublicBoldFont [UIFont boldSystemFontOfSize:15]
#define PublicBigBoldFont [UIFont boldSystemFontOfSize:18]
#define PublicBigFont [UIFont systemFontOfSize:18]

#define KeyBoardHeight 216
#define UpHeight 64.0
#define UpHeightInset UpHeight - 20.0
#define verticalHeight 15.0
#define levelSpace  10.0
#define ButtonHeight 44.0
#define Padding 3.0
#define NormalSpace 5.0
#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

#define DEVICEMODEL @"model"
#define DEVICENAME @"name"
#define DEVICEVERSION @"deviceVersion"
#define DEVICEID @"deviceID"
#define DEVICEXH @"deviceXH"
#define APPNAME @"appName"
#define OSVERSION @"osVersion"
#define APPVERSION @"appVersion"
#define NETDOMAIN @"netDomain"

#endif
