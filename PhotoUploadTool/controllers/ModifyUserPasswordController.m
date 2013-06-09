//
//  ModifyUserPasswordController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-29.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ModifyUserPasswordController.h"
#import "UserObjDao.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
@interface ModifyUserPasswordController ()

@end

@implementation ModifyUserPasswordController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    self.tabbarTitleLabel.text = @"修改密码";
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height +300);
	// Do any additional setup after loading the view.
    [self setViewData];
    self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height};
}

-(void)setViewData{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.nameField setText:appDelegate.user.userName];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)keyboardDown:(id)sender{
    float durationTime = [[[(NSNotification*)sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:durationTime animations:^{
        self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height};
    }];
}
- (void)viewDidUnload {
    [self setNameField:nil];
    [self setOldPwdField:nil];
    [self setReNewPwdField:nil];
    [self setDNewPwdField:nil];
    [self setScrollView:nil];
    [self setTabbarTitleLabel:nil];
    [super viewDidUnload];
}
- (IBAction)okBtClicked:(id)sender {
    if ([self checkInputStr]) {
        [self userTapGesture:nil];
        NSString *dNewPwStr = [self.dNewPwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        ModifyUserPasswordController __weak *weakCtr = self;
        
        [UserObjDao modifyUserPwdUserObjId:appDelegate.user.userId withUserPwd:dNewPwStr withSuccess:^(NSString *success) {
            ModifyUserPasswordController *modifyCtr = weakCtr;
            [MBProgressHUD hideHUDForView:modifyCtr.view animated:YES];
            [modifyCtr.navigationController popToRootViewControllerAnimated:YES];
        } withFailure:^(NSError *errror) {
            ModifyUserPasswordController *modifyCtr = weakCtr;
            [MBProgressHUD hideHUDForView:modifyCtr.view animated:YES];
            [modifyCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }
}

- (IBAction)backBtClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)userTapGesture:(UITapGestureRecognizer*)tapGesture{
    [self.oldPwdField resignFirstResponder];
    [self.dNewPwdField resignFirstResponder];
    [self.reNewPwdField resignFirstResponder];
}

-(BOOL)checkInputStr{
    NSString *oldpwStr = [self.oldPwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *dNewPwStr = [self.dNewPwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *reNewPwdStr = [self.reNewPwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([oldpwStr isEqualToString:@""]) {
        [self alertErrorMessage:@"原始密码不能为空"];
        return NO;
    }
    if ([dNewPwStr isEqualToString:@""]) {
        [self alertErrorMessage:@"新密码不能为空"];
        return NO;
    }
    if ([reNewPwdStr isEqualToString:@""]) {
        [self alertErrorMessage:@"确认新密码不能为空"];
        return NO;
    }
    if (![dNewPwStr isEqualToString:reNewPwdStr]) {
        [self alertErrorMessage:@"确认新密码不正确"];
        return NO;
    }
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (![oldpwStr isEqualToString:@""] || ![oldpwStr isEqualToString:appDelegate.user.userPwd]) {
        [self alertErrorMessage:@"原始密码不正确"];
        return NO;
    }
    return YES;
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height + 200};
    float y = [textField.superview frame].origin.y;
    [self.scrollView setContentOffset:(CGPoint){0,y} animated:YES];
}
#pragma mark --

@end
