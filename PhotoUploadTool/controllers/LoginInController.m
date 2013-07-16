//
//  LoginInController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "LoginInController.h"
#import "ForgetPasswordAlertView.h"
#import "UserObjDao.h"
#import "AppDelegate.h"
#import "ForgotPasswordController.h"
#import "DRTabBarController.h"
#define USERDEFAULT_NAME @"userdefault_name"
@interface LoginInController ()
@property (nonatomic,strong) DRTabBarController *drtabBarController;
@property(nonatomic,assign) float selfViewCenterheight;
@end

@implementation LoginInController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
}

-(void)keyboardDown:(id)sender{
    float durationTime = [[[(NSNotification*)sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:durationTime animations:^{
        self.view.center = (CGPoint){self.view.center.x,self.selfViewCenterheight};
    }];
}


-(void)keyboardUP:(id)sender{
    float durationTime = [[[(NSNotification*)sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:durationTime animations:^{
        if (self.view.frame.size.height == 460) {
            self.view.center = (CGPoint){self.view.center.x,100};
        }else{
          self.view.center = (CGPoint){self.view.center.x,250};
        }
        
        DRLOG(@"%@", NSStringFromCGRect(self.view.frame));
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"返回"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUP:) name:UIKeyboardWillShowNotification object:nil];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    self.selfViewCenterheight = self.view.center.y-20;
    [self setDefaultUser];
	// Do any additional setup after loading the view.
}


-(void)setDefaultUser{
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_NAME];
    if (name) {
        [self.userNameField setText:name];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTypeBackground:nil];
    [self setUserNameField:nil];
    [self setPasswdField:nil];
    [self setForgotPwdBt:nil];
    [self setRegisterBt:nil];
    [super viewDidUnload];
}
- (IBAction)LoginBtClicked:(id)sender {
//    self.userNameField.text = @"dd";
//    self.passwdField.text = @"dd";
    if ([self checkInputField]) {
        [self.userNameField resignFirstResponder];
        [self.passwdField resignFirstResponder];
        NSString *name = [self.userNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *passwd = [self.passwdField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:USERDEFAULT_NAME];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        AppDelegate __weak *weakAppDelegate = appDelegate;
        __weak LoginInController *weakCtr = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [UserObjDao loginInUserObjName:name withUserPwd:passwd withToken:appDelegate.token withSuccess:^(UserObj *userObj) {
            AppDelegate *delegate = weakAppDelegate;
            LoginInController *ctr = weakCtr;
            delegate.user = userObj;
            [MBProgressHUD hideHUDForView:ctr.view animated:YES];
            [self.navigationController pushViewController:self.drtabBarController animated:YES];
        } withFailure:^(NSError *errror) {
            LoginInController *ctr = weakCtr;
            [MBProgressHUD hideHUDForView:ctr.view animated:YES];
            DRLOG(@"%@",errror);
            [ctr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }
}

- (IBAction)registerBtClicked:(id)sender {
    
}

- (IBAction)forgotPasswordClicked:(id)sender {
//    [ForgetPasswordAlertView defaultAlertViewWithEmal:@"liuchong1228@126.com" withSuccess:^{
//        
//    } orFailure:^(NSError *error) {
//        
//    } orCancel:^{
//        
//    }];
}

- (IBAction)backBtClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)checkInputField{
    NSString *name = self.userNameField.text;
    NSString *passwd = self.passwdField.text;
    if ([[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self alertErrorMessage:@"用户名不能为空"];
        return NO;
    }
    
    if ([[passwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        [self alertErrorMessage:@"密码不能为空"];
        return NO;
    }
    return YES;
    
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.userNameField resignFirstResponder];
    [self.passwdField resignFirstResponder];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (sender == self.forgotPwdBt) {
        ForgotPasswordController *desCtr = segue.destinationViewController;
        desCtr.userName = self.userNameField.text;
    }else
    if (sender == self.registerBt) {
        
    }
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
}
#pragma mark --

#pragma mark property
-(DRTabBarController *)drtabBarController{

    if (!_drtabBarController) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
        _drtabBarController = (DRTabBarController*)[story instantiateViewControllerWithIdentifier:@"DRTabBarController"];
    }
    return _drtabBarController;
}
#pragma mark --

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
