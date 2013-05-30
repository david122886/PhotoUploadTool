//
//  LoginInController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "LoginInController.h"
#import "ForgetPasswordAlertView.h"
@interface LoginInController ()

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"返回"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
	// Do any additional setup after loading the view.
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
    [super viewDidUnload];
}
- (IBAction)LoginBtClicked:(id)sender {
    if ([self checkInputField]) {
        
    }
}

- (IBAction)registerBtClicked:(id)sender {
    
}

- (IBAction)forgotPasswordClicked:(id)sender {
    [ForgetPasswordAlertView defaultAlertViewWithEmal:@"liuchong1228@126.com" withSuccess:^{
        
    } orFailure:^(NSError *error) {
        
    } orCancel:^{
        
    }];
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

@end
