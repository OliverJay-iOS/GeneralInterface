//
//  GeneralTableViewCell.m
//  MobileAttendance
//
//  Created by mac  on 14-8-25.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "GeneralTableViewCell.h"
#import "PublicMethod.h"
#import <UIKit/UIKit.h>

NSString *const RestoreTableViewDidBeginScrollingNotification = @"RestoreTableViewDidBeginScrollingNotification";

@interface GeneralTableViewCell () <UIScrollViewDelegate>{
    
}


@end

@implementation GeneralTableViewCell

@synthesize bOpenScroll = _bOpenScroll ;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CGSize size = CGSizeZero;
    if(CGSizeEqualToSize(toChangedContentSize,CGSizeZero)){
        size = CGSizeMake(CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds));
    }
    else{
        size = toChangedContentSize;
    }
    if([keyPath isEqualToString:@"contentSize"] && !_bOpenScroll && !CGSizeEqualToSize(_scrollView.contentSize , size)){
        _scrollView.contentSize = size;
        return ;
    }
    
    if([keyPath isEqualToString:@"frame"] && _bChangeFrame && !CGSizeEqualToSize(toChangedSize, self.frame.size) && !CGSizeEqualToSize(CGSizeZero, toChangedSize))
    {
        NSLog(@"keypath objects = %@,%@,%@,%@",keyPath,object,change,NSStringFromCGSize(toChangedSize));
        CGRect rect = CGRectFromString([change objectForKey:@"new"]);
        self.frame = CGRectMake(rect.origin.x ,
                                rect.origin.y,
                                toChangedSize.width,
                                toChangedSize.height);
    }
}

-(void)setup {
    [_scrollView addObserver:self
                  forKeyPath:@"contentSize"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
    [self addObserver:self
                  forKeyPath:@"frame"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
    
    _bChangeFrame = NO;
    self.bOpenScroll = YES;
    [titleLabel setHidden:YES];
    [contentLabel setHidden:YES];
    [timeLabel setHidden:YES];
    toChangedSize = CGSizeZero;
    toChangedContentSize = CGSizeZero;
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.backgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0f];
    moreButton.frame = CGRectMake(0, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [moreButton setTitle:@"详情" forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(userPressedMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewButtonView addSubview:moreButton];
    
    qdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qdButton.backgroundColor = [UIColor colorWithRed:1.0f green:0.231f blue:0.188f alpha:1.0f];
    qdButton.frame = CGRectMake(kCatchWidth / 2.0f, 0, kCatchWidth / 2.0f, CGRectGetHeight(self.bounds));
    [qdButton setTitle:@"签到" forState:UIControlStateNormal];
    [qdButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [qdButton addTarget:self action:@selector(userPressedQDButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewButtonView addSubview:qdButton];
    
    lineView = [PublicMethod getSepratorLine:CGRectMake(0, CGRectGetHeight(self.frame) - 0.6, CGRectGetWidth(self.frame) , 0.6) alpha:0.3];
    [lineView setHidden:YES];
    [_scrollViewContentView addSubview:lineView];
    
    displayWebView.scalesPageToFit = YES;
	displayWebView.backgroundColor = [UIColor clearColor];
	displayWebView.opaque = NO;
    [PublicMethod hideGradientBackground:displayWebView];
    
    contentImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    contentImageView.layer.cornerRadius = 2;
    contentImageView.layer.masksToBounds = YES;
    contentImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:contentImageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enclosingTableViewDidScroll)
                                                 name:RestoreTableViewDidBeginScrollingNotification
                                               object:nil];
}

-(void)enclosingTableViewDidScroll {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)userPressedQDButton:(id)sender {
    [self.delegate cellDidSelectQD:self];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(void)userPressedMoreButton:(id)sender {
    [self.delegate cellDidSelectMore:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) + kCatchWidth, CGRectGetHeight(self.bounds));
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.scrollViewButtonView.frame = CGRectMake(CGRectGetWidth(self.bounds) - kCatchWidth, 0, kCatchWidth, CGRectGetHeight(self.bounds));
    self.scrollViewContentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    self.scrollView.scrollEnabled = !self.editing;
    self.scrollViewButtonView.hidden = editing;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
//    NSLog(@"contentoffset endDrag =%f,%f,%@,%@",scrollView.contentOffset.x,scrollView.contentOffset.y,scrollView,NSStringFromCGSize(_scrollView.contentSize));
    if (scrollView.contentOffset.x >= (scrollView.contentSize.width - screenWidth)/2) {
        targetContentOffset->x = scrollView.contentSize.width - screenWidth;
    }
    else {
        *targetContentOffset = CGPointZero;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [scrollView setContentOffset:CGPointZero animated:YES];
        });
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointZero;
    }
    
    self.scrollViewButtonView.frame = CGRectMake(scrollView.contentOffset.x + (CGRectGetWidth(self.bounds) - kCatchWidth), 0.0f, kCatchWidth, CGRectGetHeight(self.bounds));
}

- (void)dealloc{
    NSLog(@"tableviewcell 回收");
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self removeObserver:self forKeyPath:@"frame"];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:RestoreTableViewDidBeginScrollingNotification object:nil];
    
    [titleLabel removeFromSuperview];
    titleLabel = nil;
    [contentLabel removeFromSuperview];
    contentLabel = nil;
    [time1Label removeFromSuperview];
    time1Label = nil;
    [timeLabel removeFromSuperview];
    timeLabel = nil;
    [time2Label removeFromSuperview];
    time2Label = nil;
    [lineView removeFromSuperview];
    lineView = nil;
    [eventControl removeFromSuperview];
    eventControl = nil;
    [_scrollView removeFromSuperview];
    _scrollView = nil;
    [_scrollViewButtonView removeFromSuperview];
    _scrollViewButtonView = nil;
    [_scrollViewContentView removeFromSuperview];
    _scrollViewContentView = nil;
    [displayWebView removeFromSuperview];
    displayWebView = nil;
    [contentImageView removeFromSuperview];
    contentImageView = nil;
    _delegate = nil;
    
}

@end
