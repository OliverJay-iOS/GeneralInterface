//
//  CustomIntroductionView.m
//  ApexiPhoneOpenAccount
//
//  Created by mac  on 14-6-6.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "CustomIntroductionView.h"
#import "MYIntroductionPanel.h"

#define IMAGEVIEWTAG 1011

@interface CustomIntroductionView () {
    NSMutableArray * Panels;
    int currentPanelIndex;
    UIButton * _beginUseButton;
}

@end

@implementation CustomIntroductionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame headerText:(NSString *)headerText panels:(NSArray *)panels
{
    self = [super initWithFrame:frame];
    if (self) {
        Panels = [panels mutableCopy];
        
        contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        contentScrollView.pagingEnabled = YES;
        contentScrollView.showsHorizontalScrollIndicator = NO;
        contentScrollView.showsVerticalScrollIndicator = NO;
        contentScrollView.delegate = self;
        [self addSubview:contentScrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((self.frame.size.width - 185)/2,
                                                                      self.frame.size.height - 40, 185, 40)];
        pageControl.numberOfPages = Panels.count;
        [self addSubview:pageControl];
        
        for (int i = 0 ;i < panels.count ;i++) {
            MYIntroductionPanel * panel = [Panels objectAtIndex:i];
            UIImageView *panelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(i * self.frame.size.width, 0 , self.frame.size.width , self.frame.size.height)];
            panelImageView.tag = IMAGEVIEWTAG + i;
            panelImageView.contentMode = UIViewContentModeScaleToFill;
            panelImageView.backgroundColor = [UIColor clearColor];
            panelImageView.image = panel.Image;
            NSLog(@"panel.image =%@",panel.Image);
//            panelImageView.layer.cornerRadius = 3;
            panelImageView.clipsToBounds = YES;
            [contentScrollView addSubview:panelImageView];
            
            contentScrollView.contentSize = CGSizeMake((i+1) * self.frame.size.width, self.frame.size.height);
        }
    }
    return self;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"CONTENToffset.x =%f",contentScrollView.contentOffset.x);
//    if (currentPanelIndex == (Panels.count - 1)) {
//        self.alpha = ((contentScrollView.frame.size.width * Panels.count) - contentScrollView.contentOffset.x) /
//                     contentScrollView.frame.size.width;
//    }
//    if (currentPanelIndex == 0) {
//        self.alpha = (contentScrollView.frame.size.width + contentScrollView.contentOffset.x) /
//                     contentScrollView.frame.size.width;
//    }
    
    if(contentScrollView.contentOffset.x < 0){
        [scrollView setScrollEnabled:NO];
        [scrollView performSelector:@selector(setScrollEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
    if(contentScrollView.contentOffset.x > (contentScrollView.frame.size.width * (Panels.count - 1))){
        [scrollView setScrollEnabled:NO];
        [scrollView performSelector:@selector(setScrollEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.4];
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    if(contentScrollView.contentOffset.x < 0){
//        return NO;
//    }
//    if(contentScrollView.contentOffset.x > (contentScrollView.frame.size.width * Panels.count)){
//        return NO;
//    }
//    return YES;
//}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    currentPanelIndex = scrollView.contentOffset.x / contentScrollView.frame.size.width;
    
    if (currentPanelIndex == (Panels.count)) {
        if ([(id)_delegate respondsToSelector:@selector(introductionDidFinishWithType:)]) {
            [_delegate introductionDidFinishWithType:MYFinishTypeSwipeOut];
        }
    }
    else {
        int LastPanelIndex = pageControl.currentPage;
        pageControl.currentPage = currentPanelIndex;
        
        if(pageControl.currentPage == Panels.count - 1 ){
            if(_beginUseButton == nil){
                _beginUseButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 200/2,
                                                                             self.frame.size.height - 44 - 44,
                                                                             200,
                                                                             60)];
//                [_beginUseButton setTitle:@"开始使用" forState:UIControlStateNormal];
                _beginUseButton.titleLabel.textColor = [UIColor whiteColor];
                [_beginUseButton addTarget:self action:@selector(skipIntroduction) forControlEvents:UIControlEventTouchUpInside];
                
                UIView * view = [self viewWithTag:IMAGEVIEWTAG + Panels.count - 1];
                [view setUserInteractionEnabled:YES];
                [view addSubview:_beginUseButton];
            }
            else{
                [_beginUseButton setHidden:NO];
            }
        }
        else {
            [_beginUseButton setHidden:YES];
        }
        
//        [UIView animateWithDuration:0.3 animations:^{
//            [[self viewWithTag:IMAGEVIEWTAG + currentPanelIndex] setAlpha:1];
//        }];
        
//        CATransition *transition = [CATransition animation];
//        transition.duration = 0.3;
//        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//        transition.type = kCATransitionFade;
//        [[self viewWithTag:IMAGEVIEWTAG + currentPanelIndex].layer addAnimation:transition forKey:@"transition"];
        
        if (LastPanelIndex != currentPanelIndex) {
            if ([(id)_delegate respondsToSelector:@selector(introductionDidChangeToPanel:withIndex:)]) {
                [_delegate introductionDidChangeToPanel:Panels[currentPanelIndex] withIndex:currentPanelIndex];
            }
        }
    }
}

-(void)showInView:(UIView *)view{
    self.alpha = 0;
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

-(void)hideWithFadeOutDuration:(CGFloat)duration{
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:nil];
}

-(void)skipIntroduction{
    if ([(id)_delegate respondsToSelector:@selector(introductionDidFinishWithType:)]) {
        [_delegate introductionDidFinishWithType:MYFinishTypeSkipButton];
    }
    
    [self hideWithFadeOutDuration:0.3];
}

@end
