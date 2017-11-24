//
//  CustomAlertView.h
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-3-9.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "CustomAlertViewManager.h"
#import "ShareHeader.h"

//typedef enum {
//    RESIGNRESPONSE_MESSAGE = 0,
//    
//} AlertView_Message;

@interface CustomAlertView : UIView<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,UIAlertViewDelegate,UISearchBarDelegate>
{
    @private
    int selfTipIndex;
    NSString *_title;
    
    @public
//    FilterDataClass * filterClass;
//    UIView * textView;
    UITableView * selectView;
    UITableView * filterResultView;
    UIWebView * webView;
    UIButton * okButton;
    UINavigationBar * alertNavigationBar;
    SELECT_DATA_TYPE data_type;
    
    id target;
    SEL disMissCustomAlertViewSEL;
    NSMutableArray * filterArray;                   //源数据
    NSMutableArray * filterSourceArray;             //过滤后的数据
    NSMutableArray * selectData;
    UIButton * closeButton;
    UIActivityIndicatorView * indicatorView;
    
    MBProgressHUD * alertHUD;
    NSString * htmlKey ;
    BOOL bCanSearch;                        //是否允许搜索
    CustomAlertViewManager * manager;
    UILabel * titleLabel;
    UIButton * sureButton;
    UIButton * cancelButton;
    CGRect normalSelectViewRect;
    
    UIScrollView * segmentScrollView;
    NSArray * segmentTitles;
}

- (void)setSegmentTitles:(NSArray *)ar;

//设置标题内容
- (void) toSetTitleLabel:(NSString *)title;

- (void) setTarget:(id)_target withSEL:(SEL)_select;

- (void) setSelfTipIndex;

- (void) updateUIThread:(BOOL)isFirst;

- (void) createMBProgress;

- (void) dismissHUD;

- (void) setOKHidden:(BOOL)isShow;

- (void) setTitle:(NSString *)title;

- (void) resignAllResponser;

//让搜索栏出现，并且重新布局文件
- (void) setShowSearchAndRelayoutSubviews:(NSString *)sSearchBarPlaceHolder;

- (id) initWithFrame:(CGRect)frame target:(CustomAlertViewManager *)_manager;

- (void)setCompleteBlock:(void (^)(NSArray *)) sureBlock cancelBlock:(void (^)(NSString *)) cancelBlock;

@end







