//
//  CustomAlertViewManager.m
//  GeneralInterface
//
//  Created by mac  on 14-8-30.
//  Copyright (c) 2014年 mac . All rights reserved.
//

#import "CustomAlertViewManager.h"
#import "PublicMethod.h"

@interface CustomAlertViewManager(){
    UITextField * focusTextField;
    float keyboardOffset;
    BOOL bKeyboardShow;
    
    CGRect rKeyboardFrame;
}

@end

@implementation CustomAlertViewManager

- (id)init{
    self = [super init];
    if(self){
        focusTextField = nil;
        keyboardOffset = 0;
        bKeyboardShow = NO;
        bChangeparam = NO;
        iSegmentSelectIndex = 0;
        rKeyboardFrame = CGRectZero;
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector (OnKeyboardChangeFrame:) name: UIKeyboardDidChangeFrameNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFieldTextChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)onFieldTextChanged:(NSNotification *)noti{
    UITextField * textField = noti.object;
    GeneralTableViewCell * cell = (GeneralTableViewCell *)[PublicMethod onGetTableViewCellBySubview:textField];
    NSIndexPath * indexpath = [observeTableView indexPathForCell:cell];
    NSLog(@"cell indexpath = %@,%@,%@",cell,indexpath,textField.text);
    NSString * fieldText = [PublicMethod trimSpaceAndNewLine:[NSString stringWithFormat:@"%@", textField.text]];
    NSLog(@"cell indexpath = %@",fieldText);
    
    switch (mode) {
        case ALERTVIEW_SEGMENT_MODE:{
            [[tableDataSource objectAtIndex:iSegmentSelectIndex] replaceObjectAtIndex:indexpath.row + 1 withObject:fieldText];
            break;
        }
        case ALERTVIEW_INPUTFIELD_MODE:{
            NSMutableArray * ar = [tableDataSource objectAtIndex:indexpath.section];
            [ar replaceObjectAtIndex:indexpath.row withObject:fieldText];
            [tableDataSource replaceObjectAtIndex:indexpath.section withObject:ar];
            break;
        }
        default:
            break;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int i = 0;
    switch (mode) {
        case ALERTVIEW_INPUTFIELD_MODE:
            i = tableDataSource.count > 0 ? 1 : 0;
            break;
            
        case ALERTVIEW_SEGMENT_MODE:{
            i = tableDataSource.count > 0 ? 1 : 0;
            break;
            
        default:
            break;
        }
    }
    
    return i;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int i = 0;
    switch (mode) {
        case ALERTVIEW_INPUTFIELD_MODE:
            i = ((NSArray *)[tableDataSource objectAtIndex:section]).count;
            break;
            
        case ALERTVIEW_SEGMENT_MODE:{
            i = cellTitles.count;
            break;
            
        default:
            break;
        }
    }
    
    return i;
}

static NSString *rosterItemTableIdentifier = @"alertCell";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	GeneralTableViewCell *cell = (GeneralTableViewCell * ) [tableView dequeueReusableCellWithIdentifier:rosterItemTableIdentifier];
    cell.delegate = self;
    NSString * nibName = @"ViewCell";
    
	if (cell == nil)
	{
		cell = [[[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil] objectAtIndex: 0];
        [tableView registerNib:[UINib nibWithNibName:nibName bundle:nil] forCellReuseIdentifier:rosterItemTableIdentifier];
	}
    
    [self configCell:cell indexPath:indexPath tableview:tableView];
	
	return cell;
}

- (void)configCell:(GeneralTableViewCell *)cell indexPath:(NSIndexPath *)indexPath tableview:(UITableView *)tableview{
    [cell.scrollViewContentView setBackgroundColor:[UIColor whiteColor]];
    [cell.scrollView setBackgroundColor:[UIColor whiteColor]];
    [cell.scrollViewButtonView setBackgroundColor:[UIColor whiteColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell->inputField.delegate = nil;
    cell->inputField.delegate = self;
    
    for (UIView * view in cell->inputField.subviews) {
        [view removeFromSuperview];
    }
    
    cell.bOpenScroll = NO;
    cell.scrollView.contentSize = CGSizeMake(CGRectGetWidth(cell.bounds) , CGRectGetHeight(cell.bounds));
    
    switch (mode) {
        case ALERTVIEW_INPUTFIELD_MODE:
        {
            [cell->titleLabel setHidden:NO];
            [cell->inputField setHidden:NO];
            [cell->lineView setHidden:NO];
            [cell->titleLabel setText:[[cellTitles objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            //在联系人后面加一个加的图标
//            NSString *lxr=@"联系人";
//            BOOL result=[lxr isEqualToString:[[cellTitles objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
//            if(result){
//                
//                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"add_contacts.png"]];
//                cell.accessoryView = imageView;
//                [imageView setUserInteractionEnabled:YES];
//                
//                UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addcontact:) ];
//                
//                [imageView addGestureRecognizer:doubleTapRecognizer];
//                
//            }
            
            
            if(cellPlaceHolders && cellPlaceHolders.count > 0){
                [cell->inputField setPlaceholder:[[cellPlaceHolders objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            }
            if(tableDataSource && tableDataSource.count > 0){
                [cell->inputField setText:[[tableDataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
            }
       
        }
            break;
            
        case ALERTVIEW_SEGMENT_MODE:
        {
            [cell->titleLabel setHidden:NO];
            [cell->inputField setHidden:NO];
            [cell->lineView setHidden:NO];
            [cell->contentImageView setHidden:NO];
            
            [cell->titleLabel setText:[cellTitles objectAtIndex:indexPath.row]];
            if(tableDataSource && tableDataSource.count > 0){
                [cell->inputField setText:[[tableDataSource objectAtIndex:iSegmentSelectIndex] objectAtIndex:indexPath.row + 1]];
            }
        }
    }
    
    if(cellEditBlock){
        cellEditBlock(indexPath,cell,tableview);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return fCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (dispatchAlertViewMessage && bKeyboardShow) {
        bKeyboardShow = NO;
        dispatchAlertViewMessage(focusTextField , ALERTVIEW_INPUTFIELD_MODE , 0);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    GeneralTableViewCell * cell = (GeneralTableViewCell *)[PublicMethod onGetTableViewCellBySubview:textField];
    NSIndexPath * indexpath = [observeTableView indexPathForCell:cell];
    NSLog(@"cell indexpath = %@,%@",cell,indexpath);
    NSString * fieldText = [PublicMethod trimSpaceAndNewLine:[NSString stringWithFormat:@"%@%@", textField.text , string]];
    
    switch (mode) {
        case ALERTVIEW_SEGMENT_MODE:{
            bChangeparam = YES;
            break;
        }
        case ALERTVIEW_INPUTFIELD_MODE:{
            
            break;
        }
        default:
            break;
    }
    
    return YES;
}

#pragma textfield Delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //调整page的位置
    if (dispatchAlertViewMessage && bKeyboardShow) {
        bKeyboardShow = NO;
        dispatchAlertViewMessage(textField , ALERTVIEW_INPUTFIELD_MODE ,0);
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (dispatchAlertViewMessage && bKeyboardShow) {
        bKeyboardShow = NO;
        dispatchAlertViewMessage(textField , ALERTVIEW_INPUTFIELD_MODE,0);
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    focusTextField = textField;
    CGRect frame = [focusTextField.superview convertRect:focusTextField.frame toView:[UIApplication sharedApplication].keyWindow];
    if(!CGRectEqualToRect(rKeyboardFrame, CGRectZero)){
        keyboardOffset = frame.origin.y + frame.size.height + 2 + ButtonHeight - rKeyboardFrame.origin.y;
        NSLog(@"当前beginedit的frame = %@,%f",NSStringFromCGRect(frame),keyboardOffset);
        if(keyboardOffset > 0 && dispatchAlertViewMessage){
            dispatchAlertViewMessage(focusTextField , ALERTVIEW_MOVE_UP , keyboardOffset);
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    focusTextField = textField;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

-(void)OnKeyboardChangeFrame:(NSNotification *)aNotification{
    bKeyboardShow = YES;
    NSDictionary *userInfo =[aNotification userInfo];
    CGRect keyboardFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
    CGRect frame = [focusTextField.superview convertRect:focusTextField.frame toView:[UIApplication sharedApplication].keyWindow];
    keyboardOffset = frame.origin.y + frame.size.height + 2 + ButtonHeight - keyboardFrame.origin.y;
    rKeyboardFrame = keyboardFrame;
    NSLog(@"当前field的frame = %@,%@,%f,%@",NSStringFromCGRect(frame),NSStringFromCGRect(keyboardFrame),keyboardOffset,aNotification);
    if(keyboardOffset > 0 && dispatchAlertViewMessage){
        dispatchAlertViewMessage(focusTextField , ALERTVIEW_MOVE_UP , keyboardOffset);
    }
}

- (void)addcontact:(UIGestureRecognizer *)getture{
   // NSArray *array = [[NSArray alloc] initWithObjects:
   //                   @"",@"",@"",nil];
    
   // [observeTableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
    observeTableView.delegate = nil;
    observeTableView.dataSource = nil;
    observeTableView = nil;
    
    [tableDataSource removeAllObjects];
    tableDataSource = nil;
    cellTitles = nil;
    cellPlaceHolders = nil;
    cellEditBlock = nil;
    dispatchAlertViewMessage = nil;
    focusTextField = nil;
}


@end
