//
//  CustomAlertViewManager.h
//  GeneralInterface
//
//  Created by mac  on 14-8-30.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralTableViewCell.h"

typedef enum {
    ALERTVIEW_INPUTFIELD_MODE = 0,          //表示uitextfield的模式
    ALERTVIEW_SEGMENT_MODE = 4,             //表示segment模式
    ALERTVIEW_MOVE_UP = 1,                  //让alertview向上移动
    ALERTVIEW_MOVE_DOWN = 2                 //让alertview向下移动
} ALERTVIEW_MODE;

@protocol CustomAlertViewManagerDelegate <NSObject>

- (void)configTableViewCell:(GeneralTableViewCell *)cell tableView:(UITableView *)tableView indexpath:(NSIndexPath *)indexpath;

@end

@interface CustomAlertViewManager : NSObject<UITableViewDataSource,UITableViewDelegate,GeneralTableViewCellDelegate,UITextFieldDelegate>
{
    @public
    float fCellHeight ;
    NSMutableArray * tableDataSource;
    NSMutableArray * cellTitles;
    NSMutableArray * cellPlaceHolders;
    ALERTVIEW_MODE mode;
    BOOL bChangeparam;
    int iSegmentSelectIndex;
    void (^cellEditBlock)(NSIndexPath * , GeneralTableViewCell * ,UITableView *) ;
    void (^dispatchAlertViewMessage)(UITextField * , ALERTVIEW_MODE , float) ;
    UITableView * observeTableView;
    
}

@property (nonatomic,weak) id<CustomAlertViewManagerDelegate> delegate;

@end
