//
//  ForgotPasswordController.m
//  PhotoUploadTool
//
//  Created by david on 13-6-4.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ForgotPasswordController.h"
#import "MBProgressHUD.h"
#import "UserObjDao.h"
#import "AppDelegate.h"
@interface ForgotPasswordController ()

@end

@implementation ForgotPasswordController

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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    self.tabbarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarbg.png"]];
    self.tabbarTitleLabel.text = @"忘记密码";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    self.nameField.delegate = self;
    self.pwdField.delegate =self;
    self.rePwdField.delegate = self;
    self.emailField.delegate = self;
    self.nameField.text = self.userName;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"registerbg.png"]];
	// Do any additional setup after loading the view.
}

-(void)identifyEmail{
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    ForgotPasswordController __weak *weakCtr= self;
    NSString *nameStr = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailStr = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [UserObjDao identifyEmailUserObjName:nameStr withEmail:emailStr withSuccess:^(UserObj *userObj) {
        ForgotPasswordController *forgotCtr = weakCtr;
        [forgotCtr modifyPassword:userObj];
    } withFailure:^(NSError *errror) {
        ForgotPasswordController *forgotCtr = weakCtr;
        [MBProgressHUD hideHUDForView:forgotCtr.view.window animated:YES];
        [forgotCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

-(void)modifyPassword:(UserObj*)user{
    NSString *pwStr = [self.pwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AppDelegate __weak *weakDelegate = appDelegate;
    __weak UserObj *weakUser = user;
    ForgotPasswordController __weak *weakCtr= self;
    
    user.userPwd = pwStr;
    [UserObjDao modifyUserPwdUserObjId:user.userId withUserPwd:pwStr withSuccess:^(NSString *success) {
        weakDelegate.user = weakUser;
        ForgotPasswordController *forgotCtr = weakCtr;
        [MBProgressHUD hideHUDForView:forgotCtr.view.window animated:YES];
        [forgotCtr modifyPwdSuccess];
    } withFailure:^(NSError *errror) {
        ForgotPasswordController *forgotCtr = weakCtr;
        [MBProgressHUD hideHUDForView:forgotCtr.view.window animated:YES];
        [forgotCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

-(void)modifyPwdSuccess{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"修改密码成功，请用新密码登陆" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

-(void)keyboardDown:(id)sender{
    float durationTime = [[[(NSNotification*)sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:durationTime animations:^{
        self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height};
    }];
}
-(BOOL)checkInputStr{
    NSString *nameStr = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pwStr = [self.pwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rePwStr = [self.rePwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailStr = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([nameStr isEqualToString:@""]) {
        [self alertErrorMessage:@"用户名不能为空"];
        return NO;
    }
    if ([pwStr isEqualToString:@""]) {
        [self alertErrorMessage:@"密码不能为空"];
        return NO;
    }
    if ([rePwStr isEqualToString:@""]) {
        [self alertErrorMessage:@"确认密码不能为空"];
        return NO;
    }
    if ([emailStr isEqualToString:@""]) {
        [self alertErrorMessage:@"邮箱地址不能为空"];
        return NO;
    }
    if (![rePwStr isEqualToString:pwStr]) {
        [self alertErrorMessage:@"确认密码不正确"];
        return NO;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES '\\\\w+([-+.]\\\\w+)*@\\\\w+([-.]\\\\w+)*\\\\.\\\\w+([-.]\\\\w+)*'"];
    if (![predicate evaluateWithObject:emailStr]){
        [self alertErrorMessage:@"无效邮箱地址"];
        return NO;
    }
    return YES;
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameField:nil];
    [self setPwdField:nil];
    [self setRePwdField:nil];
    [self setEmailField:nil];
    [self setScrollView:nil];
    [self setTabbarView:nil];
    [self setTabbarTitleLabel:nil];
    [super viewDidUnload];
}
- (IBAction)OKBtClicked:(UIButton *)sender {
    if ([self checkInputStr]) {
        [self userTapGesture:nil];
        [self identifyEmail];
    }
}

-(void)userTapGesture:(UITapGestureRecognizer*)tapGesture{
    [self.nameField resignFirstResponder];
    [self.pwdField resignFirstResponder];
    [self.rePwdField resignFirstResponder];
    [self.emailField resignFirstResponder];
}
- (IBAction)backBtClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height + 200};
    float y = [textField.superview frame].origin.y;
    [self.scrollView setContentOffset:(CGPoint){0,y} animated:YES];
}
#pragma mark --


#pragma mark UIAlertViewDelegate
-(void)alertViewCancel:(UIAlertView *)alertView{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --
@end
