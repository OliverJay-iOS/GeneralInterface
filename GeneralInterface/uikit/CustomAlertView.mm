//
//  CustomAlertView.m
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-3-9.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "CustomAlertView.h"
#import "MBProgressHUD.h"
#import "PublicMethod.h"
#import "UIKit+custom_.h"


@interface CustomAlertView(){
    void (^ sureBlock)(NSArray *) ;
    void (^ cancelBlock)(NSString *) ;
    UISearchBar * searchBar ;
}

@end

@implementation CustomAlertView

#define  SelfFrameWidth self.frame.size.width
#define  SelfFrameHeight self.frame.size.height

#define SEGMENT_TAG 132

- (id)initWithFrame:(CGRect)frame target:(CustomAlertViewManager *)_manager{
    manager = _manager;
    self = [self initWithFrame:frame];
    if(self){
        
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfig];
        [self initWidgets];
    }
    return self;
}

- (void)setTarget:(id)_target withSEL:(SEL)_select{
    target = _target;
    disMissCustomAlertViewSEL = _select;
}

- (void) initConfig{
    bCanSearch = NO;
    selfTipIndex = -1;
    filterSourceArray = nil;
    selectData = [NSMutableArray array];
}

- (void) initWidgets{
    [self setBackgroundColor:[UIColor whiteColor]];
    self.layer.cornerRadius = 2;
    self.layer.masksToBounds = YES;
    float spaceW = 2;
    float spaceH = 40;
    
//    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0,0,SelfFrameWidth, spaceH)];
//    titleLab.text = _title;
//    titleLab.backgroundColor = [UIColor darkGrayColor];
//    titleLab.textColor = [UIColor whiteColor];
//    [self addSubview:titleLab];
    
    {
        alertNavigationBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, SelfFrameWidth, ButtonHeight)];
        
        titleLabel = [PublicMethod initLabelWithFrame:CGRectMake(0, 0, screenWidth, 44) title:nil target:alertNavigationBar];
        [titleLabel setTextColor:[UIColor whiteColor]];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        
        closeButton = [PublicMethod CreateButton:@"关闭" withFrame:CGRectMake(SelfFrameWidth - 60, 0, 60, ButtonHeight) tag:0 target:alertNavigationBar];
        [closeButton addTarget:self action:@selector(onOKClick:) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setBackgroundColor:[UIColor clearColor]];
        
        [alertNavigationBar setBackgroundImage:[[UIImage imageNamed:@"SmallLoanBundle.bundle/images/bg_menu"] clipImagefromRect:CGRectMake(0, 8, screenWidth, 20)]
                                 forBarMetrics:UIBarMetricsDefault];
        [self addSubview:alertNavigationBar];
    }
    
    {
        searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, ButtonHeight, SelfFrameWidth, ButtonHeight)];
        [searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:searchBar.frame.size]];
        searchBar.translucent = NO;
        searchBar.delegate = self;
        [searchBar setHidden:YES];
        
        [self addSubview:searchBar];
    }
    
    //    screenWidth - 2 * levelSpace  screenHeight - 20 - verticalHeight * 2
    int space = 2;
    webView = [[UIWebView alloc]initWithFrame:CGRectMake(space,ButtonHeight , SelfFrameWidth - 2* space , SelfFrameHeight - 44 - space)];
    
    //    webView = [[UIWebView alloc]initWithFrame:CGRectMake(spaceW,spaceH , SelfFrameWidth - 2* spaceW , SelfFrameHeight - 44 - spaceH)];
    webView.layer.cornerRadius = 2;
    webView.scalesPageToFit = YES;
	webView.backgroundColor = [UIColor whiteColor];
	webView.opaque = NO;
    webView.delegate = self;
    [webView setHidden:YES];
    [self addSubview:webView];
    
    normalSelectViewRect = self.frame;
    selectView = [[UITableView alloc]initWithFrame:CGRectMake(0, ButtonHeight, SelfFrameWidth, SelfFrameHeight - ButtonHeight - ButtonHeight - 2*NormalSpace) style:UITableViewStylePlain];
    
    UIView * backView = [[UIView alloc]initWithFrame:selectView.frame];
    [backView setBackgroundColor:[UIColor whiteColor]];
    [selectView setBackgroundView:backView];
    selectView.delegate = manager;
    selectView.dataSource = manager;
    manager->observeTableView = selectView;
    
    if (manager->mode == ALERTVIEW_SEGMENT_MODE) {
        indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setFrame:CGRectMake(selectView.frame.size.width/2 - 30/2,
                                           selectView.frame.size.height/2 - 30/2,
                                           30,
                                           30)];
        [indicatorView setHidesWhenStopped:YES];
        [indicatorView startAnimating];
        [selectView addSubview:indicatorView];
    }
    
    __weak __typeof(CustomAlertView *)weakSelf = self;
    manager->dispatchAlertViewMessage = ^(UITextField * textField, ALERTVIEW_MODE mode , float keyboardOffset){
        __strong __typeof(CustomAlertView *)strongSelf = weakSelf;
        switch (mode) {
            case ALERTVIEW_SEGMENT_MODE:
            case ALERTVIEW_INPUTFIELD_MODE:{
                [strongSelf resignAllResponser];
                break;
            }
            case ALERTVIEW_MOVE_UP:{
                [UIView animateWithDuration:0.2 animations:^{
                    CGRect rect = strongSelf.frame;
                    rect.origin.y = rect.origin.y - keyboardOffset;
                    strongSelf.frame = rect;
                }];
                break;
            }
            case ALERTVIEW_MOVE_DOWN:{
                [UIView animateWithDuration:0.2 animations:^{
                    strongSelf.frame = strongSelf->normalSelectViewRect;
                }];
                break;
            }
        }
        
    };
    [selectView setHidden:YES];
    
    [selectView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [PublicMethod hideGradientBackground:webView];
    
    {
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        float fOriginY = selectView.frame.origin.y + selectView.frame.size.height + NormalSpace;
        float fButtonWidth = (CGRectGetWidth(self.frame) - 6*levelSpace)/2;
        cancelButton.frame = CGRectMake(levelSpace * 2,
                                        fOriginY,
                                        fButtonWidth,
                                        ButtonHeight);
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = PublicBigBoldFont;
        cancelButton.titleLabel.shadowColor = [UIColor grayColor];
        cancelButton.titleLabel.shadowOffset = CGSizeMake(-1, 0);
        [cancelButton setTitle:@"关 闭" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sureButton.frame = CGRectMake(levelSpace * 2 + fButtonWidth + levelSpace * 2,
                                      fOriginY,
                                      fButtonWidth,
                                      ButtonHeight);
        [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        sureButton.titleLabel.font = PublicBigBoldFont;
        sureButton.titleLabel.shadowColor = [UIColor grayColor];
        sureButton.titleLabel.shadowOffset = CGSizeMake(-1, 0);
        [sureButton setTitle:@"确 定" forState:UIControlStateNormal];
        [sureButton addTarget:self action:@selector(onClickButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:cancelButton];
        [self addSubview:sureButton];
    }
    
    UITapGestureRecognizer * singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignAllResponser)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
    
    [self addSubview:selectView];
}

- (void)setSegmentTitles:(NSArray *)ar{
    [indicatorView stopAnimating];
    segmentTitles = ar;
    segmentScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SelfFrameWidth, ButtonHeight)];
    float fSegmentWidth = SelfFrameWidth/(segmentTitles.count >= 4 ? 4:segmentTitles.count);
    for (int i = 0 ; i<segmentTitles.count ; i++) {
        NSString * segmentTitle = [segmentTitles objectAtIndex:i];
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:i == 0 ? [UIColor whiteColor] : [UIColor clearColor]];
        [btn setTitle:segmentTitle forState:UIControlStateNormal];
        btn.tag = i + SEGMENT_TAG;
        [btn addTarget:self action:@selector(onSegmentSelect:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        btn.frame = CGRectMake(i*fSegmentWidth, 0 , fSegmentWidth, ButtonHeight);
        [segmentScrollView addSubview:btn];
    }
    [segmentScrollView setContentSize:CGSizeMake(fSegmentWidth * segmentTitles.count, ButtonHeight)];
    selectView.tableHeaderView = segmentScrollView;
}

- (void)onSegmentSelect:(UIButton *)button{
    [button setBackgroundColor:[UIColor whiteColor]];
    for (UIButton * btn in segmentScrollView.subviews) {
        if(btn != button){
            btn.backgroundColor = [UIColor clearColor];
        }
    }
    manager->iSegmentSelectIndex = button.tag - SEGMENT_TAG;
    [selectView reloadData];
}

- (void)onClickButton:(id)sender{
    if(sender == cancelButton){
        if(cancelBlock){
            cancelBlock (@"");
        }
    }
    if(sender == sureButton){
        switch (manager->mode) {
            case ALERTVIEW_INPUTFIELD_MODE:
            {
                NSArray * ar = [manager->tableDataSource objectAtIndex:0];
                if(ar && ar.count > 1){
                    NSString * param = [ar objectAtIndex:0];
                    if(param == nil|| param.length == 0){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入客户名称" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        return ;
                    }
                    param = [ar objectAtIndex:1];
                    if(param == nil|| param.length == 0){
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入客户地址" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        return;
                    }
                    if(sureBlock){
                        sureBlock (ar);
                    }
                }
            }
                break;
                
            case ALERTVIEW_SEGMENT_MODE:
            {
                if(manager->bChangeparam){
                    NSMutableArray * ar = [NSMutableArray array];
                    for (NSArray * array in manager->tableDataSource) {
                        [ar addObjectsFromArray:array];
                    }
                    if(sureBlock){
                        sureBlock (ar);
                    }
                }
                else {
                    if(sureBlock){
                        sureBlock (nil);
                    }
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void) setSelfTipIndex{
    switch (data_type) {
        case ZHIYE_DATA_TYPE:
//            selfTipIndex = [DiDiManager Instance]->currentTipZhiYeIndex;
            break;
            
        case XUELI_DATA_TYPE:
//            selfTipIndex = [DiDiManager Instance]->currentTipXueLiIndex ;
            break;
    }
    
    if(selfTipIndex != -1){
        [selectData replaceObjectAtIndex:selfTipIndex withObject:[NSNumber numberWithInt:1]];
    }
}

- (void) setShowSearchAndRelayoutSubviews:(NSString *)sSearchBarPlaceHolder{
    bCanSearch = YES;
    [searchBar setHidden:NO];
    [searchBar setPlaceholder:sSearchBarPlaceHolder];
    
    selectView.frame = CGRectMake(0,
                                  selectView.frame.origin.y + ButtonHeight,
                                  SelfFrameWidth,
                                  selectView.frame.size.height - ButtonHeight);
}

- (void) setOKHidden:(BOOL)hidden{
    if(hidden){
        [okButton setHidden:YES];
        CGRect rect = selectView.frame;
        [selectView setFrame:CGRectMake(rect.origin.x,
                                     rect.origin.y,
                                     rect.size.width,
                                     rect.size.height + 44)];
    }
    else{
        [okButton setHidden:NO];
    }
}

- (void) setTitle:(NSString *)title{
    if (_title) {
        _title = nil;
    }
    _title = title;
}

- (void) toSetTitleLabel:(NSString *)title{
    float width = [PublicMethod getStringWidth:title font:[UIFont boldSystemFontOfSize:18]];
    titleLabel.frame = CGRectMake(SelfFrameWidth/2 - width/2, 0, width, ButtonHeight);
    [titleLabel setText:title];
    if (title.length >= 10) {
        titleLabel.frame = CGRectMake(5, 0, width, ButtonHeight);
    }
}

- (void) updateUIThread:(BOOL)isOK{
    NSError *error = nil;
    
    NSString * htmlString = [NSString stringWithContentsOfFile:
                             [PublicMethod getFilePath:DOCUMENT_CACHE fileName:htmlKey]
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
    if(isOK){
        htmlString = [NSString stringWithFormat:@"<!DOCTYPE html> \n"
                      "<html>"
                      "<head><meta http-equiv=Content-Type content=textml;charset=UTF-8 /> \n"
                      "<meta name=viewport content=width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no/> \n"
                      "<meta http-equiv=Cache-Control content=no-cache/>"
                      "</head>"
                      "<body>%@</body> \n"
                      "</html>",htmlString];
        [webView loadHTMLString:htmlString baseURL:nil];
        [alertHUD hide:YES];
        alertHUD = nil;
    }
    else{
        alertHUD.labelText = @"加载失败";
        alertHUD.mode = MBProgressHUDModeText;
    }
}

- (NSString *)addDiv:(NSString *)str{
//    <div style="font-size:16px;"></div>
    NSMutableString *str1 = [NSMutableString stringWithFormat:str];
    [str1 insertString:@"<div style='font-size:16px';>" atIndex:0];
    [str1 appendString:@"</div>"];
    return [NSString stringWithFormat:str1];
}

- (void)dismissHUD{
    [alertHUD setHidden:YES];
    [self sendSubviewToBack:alertHUD];
    [alertHUD removeFromSuperview];
    alertHUD = nil;
}

- (void) createMBProgress{
    alertHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
    alertHUD.animationType = MBProgressHUDAnimationZoomOut;
    [alertHUD setHidden:YES];
    [alertHUD setOpaque:YES];
}

- (void) onOKClick:(UIButton *)button{
    
}

#pragma tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"filterArray  =%@",filterArray );
    return filterArray ? filterArray.count:0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"tableViewCellIdentify";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
	{
        cell.backgroundColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = [[[NSBundle mainBundle] loadNibNamed:@"tableViewCell" owner:self options:nil] objectAtIndex: 0];
        [tableView registerNib:[UINib nibWithNibName:@"tableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
	}
    
    [cell.textLabel setText:Nil];
    NSDictionary * itemDic = [filterArray objectAtIndex:indexPath.row];
    
    if(itemDic){
        [cell.textLabel setText:[itemDic objectForKey:@"NOTE"]];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:[PublicMethod getSepratorLine:CGRectMake(0, 50-1, cell.frame.size.width, 1) alpha:0.5]];
    
    if([[selectData objectAtIndex:indexPath.row] intValue] == 1){
        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *ce=[tableView cellForRowAtIndexPath:indexPath];
    [ce setSelected:NO];
    
    int index=indexPath.row;
//    int section = indexPath.section;
    
    if([selectData objectAtIndex:index] == [NSNumber numberWithInt:0]){
        ce.accessoryType=UITableViewCellAccessoryCheckmark;
        
        for (int i=0;i< selectData.count; i++) {
            NSNumber * sign = ([selectData objectAtIndex:i]);
            if([sign intValue] == 1){
                [selectData replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
            }
        }
        
        switch (data_type) {
            case ZHIYE_DATA_TYPE:
                
                break;
                
            case XUELI_DATA_TYPE:
                
                break;
        }
        
        selfTipIndex = index;
        
        [selectData replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:1]];
    }
    else{
        [selectData replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:0]];
        ce.accessoryType=UITableViewCellAccessoryNone;
    }
    
    [selectView reloadData];
    
    [self onOKClick:nil];
}

#pragma webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
//    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '300%'"];
    
//    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.fontSize=%f",80.0];
//    [webView stringByEvaluatingJavaScriptFromString:jsString];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
//	filterArray = [[DiDiManager Instance]getFilterData:filterArray originString:searchText];
//    [selectView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) _searchBar
{
// 	[self endSearchMode];
//    [searchBar setShowsCancelButton: YES animated: YES];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
//    [searchBar setShowsCancelButton: YES animated: YES];
//    if([DiDiManager Instance]->osVersion >= 7){
//        [self ChangeCancelButton:[[searchBar subviews] objectAtIndex:0]];
//    }
//    else {
//        [self ChangeCancelButton:searchBar];
//    }
}

- (void) ChangeCancelButton:(UIView *)view{
    for(id subView in [view subviews])
    {
        if([subView isKindOfClass:[UIButton class]])
        {
            UIButton *cancelButton = (UIButton *)subView;
            [cancelButton setTitle:@"取消"  forState:UIControlStateNormal];
            [cancelButton setTitleShadowColor:nil forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            if([[UIDevice currentDevice].systemVersion floatValue] < 7.0){
                [cancelButton setTintColor:PAGE_BG_COLOR];
            }
            break ;
        }
    }
}

//仅针对一个section多个row的情况
- (void)resignAllResponser{
    for (GeneralTableViewCell * cell in selectView.visibleCells) {
        [cell->inputField resignFirstResponder];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = normalSelectViewRect;
    }];
}

- (void)endSearchMode{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
//    filterArray = initSourceArray;
}

- (void)setCompleteBlock:(void (^)(NSArray *))_sureBlock cancelBlock:(void (^)(NSString *))_cancelBlock{
    sureBlock = _sureBlock;
    cancelBlock = _cancelBlock;
}

- (void)dealloc{
    NSLog(@"提醒alertview回收");
    
    [segmentScrollView removeFromSuperview];
    segmentScrollView = nil;
    [indicatorView removeFromSuperview];
    indicatorView = nil;
    target = nil;
    [selectView removeFromSuperview];
    selectView = nil;
    [filterResultView removeFromSuperview];
    filterResultView = nil;
    [webView removeFromSuperview];
    webView = nil;
    [okButton removeFromSuperview];
    okButton = nil;
    [alertNavigationBar removeFromSuperview];
    alertNavigationBar = nil;
    [filterArray removeAllObjects];
    filterArray = nil;
    [filterSourceArray removeAllObjects];
    filterSourceArray = nil;
    [selectData removeAllObjects];
    selectData = nil;
    [alertHUD removeFromSuperview];
    alertHUD = nil;
    htmlKey = nil;
}

@end















