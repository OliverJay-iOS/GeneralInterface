//
//  GeneralTableViewCell.h
//  MobileAttendance
//
//  Created by mac  on 14-8-25.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>

@class GeneralTableViewCell;

#define kCatchWidth 180

@protocol GeneralTableViewCellDelegate <NSObject>

-(void)cellDidSelectQD:(GeneralTableViewCell *)cell;
-(void)cellDidSelectMore:(GeneralTableViewCell *)cell;

@end

extern NSString *const RestoreTableViewDidBeginScrollingNotification;

//通用tableviewcell
@interface GeneralTableViewCell : UITableViewCell{
    @public
    IBOutlet UILabel * titleLabel;
    IBOutlet UILabel * contentLabel;
    IBOutlet UILabel * timeLabel;
    IBOutlet UILabel * time1Label;
    IBOutlet UILabel * time2Label;
    IBOutlet UIControl * eventControl;
    IBOutlet UIWebView * displayWebView;
    IBOutlet UITextField * inputField;
    UIImageView * contentImageView;
    UIButton *moreButton;
    UIButton *qdButton;
    UIView * lineView;
    CGSize toChangedSize;
    CGSize toChangedContentSize;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollViewContentView;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollViewButtonView;
@property (nonatomic, weak) id<GeneralTableViewCellDelegate> delegate;
@property (nonatomic) BOOL bOpenScroll;
@property (nonatomic) BOOL bChangeFrame;


@end
