//
//  CustomIntroductionView.h
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-6-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYIntroductionPanel.h"

typedef enum {
    MYFinishTypeSwipeOut = 0,
    MYFinishTypeSkipButton
}MYFinishType;

typedef enum {
    MYLanguageDirectionLeftToRight = 0,
    MYLanguageDirectionRightToLeft
}MYLanguageDirection;

@protocol MYIntroductionDelegate
@optional
-(void)introductionDidFinishWithType:(MYFinishType)finishType;
-(void)introductionDidChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex;
@end

@interface CustomIntroductionView : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate>{
    @public
    UIScrollView * contentScrollView;
    UIPageControl * pageControl;
}

@property (nonatomic) id <MYIntroductionDelegate> delegate;

- (id)initWithFrame:(CGRect)frame headerText:(NSString *)headerText panels:(NSArray *)panels;

-(void)showInView:(UIView *)view;


@end
