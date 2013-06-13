//
//  RegisterController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "RegisterController.h"
#import "MBProgressHUD.h"
#import "UserObjDao.h"
#import "AppDelegate.h"
#import "DRTabBarController.h"
#define ITEM_CANCEL @"取消"
#define ITEM_SAVE  @"保存"
@interface RegisterController ()
@property(nonatomic,strong) DRTabBarController *drtabbarController;
@end

@implementation RegisterController

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
//    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"registerbg.png"]];
    if (self.type == MODIFY_USER) {
        self.pwdLabel.text = @"新密码：";
        self.rePwdlabel.text = @"确认新密码：";
        [self.nameField setText:@""];
        self.tabbarTitleLabel.text = @"修改密码";
    }else{
        self.pwdLabel.text = @"密码：";
        self.rePwdlabel.text = @"确认密码：";
        self.tabbarTitleLabel.text = @"注册";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDown:) name:UIKeyboardWillHideNotification object:nil];
    self.nameField.delegate = self;
    self.pwField.delegate =self;
    self.rePwField.delegate = self;
    self.emailField.delegate = self;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
//    [self.navigationController.navigationBar setHidden:NO];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveUserInfo)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:ITEM_SAVE style:UIBarButtonSystemItemSave target:self action:@selector(saveUserInfo)];
//    [self.navigationItem setHidesBackButton:YES];
	// Do any additional setup after loading the view.
}


-(void)keyboardDown:(id)sender{
    float durationTime = [[[(NSNotification*)sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:durationTime animations:^{
        self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height};
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveUserInfo{
    NSLog(@"%@",self.navigationItem.rightBarButtonItem.title);
    NSString *rightItemTitle = self.navigationItem.rightBarButtonItem.title;
    if ([ITEM_CANCEL isEqualToString:rightItemTitle]) {
        //back
        [self.navigationController popViewControllerAnimated:YES];
        
    }else
    if ([ITEM_SAVE isEqualToString:rightItemTitle]) {
        //save
        [self checkInputStr];
    }
}

-(BOOL)checkInputStr{
    NSString *nameStr = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pwStr = [self.pwField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *rePwStr = [self.rePwField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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
- (void)viewDidUnload {
    [self setNameField:nil];
    [self setPwField:nil];
    [self setRePwField:nil];
    [self setEmailField:nil];
    [self setScrollView:nil];
    [self setPwdLabel:nil];
    [self setRePwdlabel:nil];
    [self setTabbarTitleLabel:nil];
    [super viewDidUnload];
}
#pragma mark UITextFieldDelegate
#pragma mark --
- (IBAction)okButtonClicked:(id)sender {
    if ([self checkInputStr]) {
        [self userTapGesture:nil];
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        AppDelegate __weak *weakDelegate = appDelegate;
        RegisterController __weak *weakRegCtr = self;
        [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        [UserObjDao registerUserObj:[self getUserObjFromView] withSuccess:^(UserObj *userObj) {
            AppDelegate *delegate = weakDelegate;
            RegisterController *gesCtr = weakRegCtr;
            delegate.user = userObj;
            [MBProgressHUD hideHUDForView:gesCtr.view.window animated:YES];
            [gesCtr registerSuccess];
        } withFailure:^(NSError *errror) {
            RegisterController *gesCtr = weakRegCtr;
            [MBProgressHUD hideHUDForView:gesCtr.view.window animated:YES];
            [gesCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
        }];
    }
}

-(void)registerSuccess{
    [self.navigationController pushViewController:self.drtabbarController animated:YES];
}

-(UserObj*)getUserObjFromView{
    NSString *nameStr = [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *pwStr = [self.pwField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailStr = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UserObj *user = [[UserObj alloc] init];
    user.userName = nameStr;
    user.userPwd = pwStr;
    user.userEmail = emailStr;
    return user;
}

-(void)userTapGesture:(UITapGestureRecognizer*)tapGesture{
    [self.nameField resignFirstResponder];
    [self.pwField resignFirstResponder];
    [self.rePwField resignFirstResponder];
    [self.emailField resignFirstResponder];
}

#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    self.scrollView.contentSize = (CGSize){self.scrollView.frame.size.width,self.scrollView.frame.size.height + 200};
    float y = [textField.superview frame].origin.y;
    [self.scrollView setContentOffset:(CGPoint){0,y} animated:YES];
}
#pragma mark --
- (IBAction)backBtClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark property
-(DRTabBarController *)drtabbarController{
    if (!_drtabbarController) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
        _drtabbarController = [story instantiateViewControllerWithIdentifier:@"DRTabBarController"];
    }
    return _drtabbarController;
}
#pragma mark --

@end
