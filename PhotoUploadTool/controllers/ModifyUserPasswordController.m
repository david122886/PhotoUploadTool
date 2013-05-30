//
//  ModifyUserPasswordController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-29.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "ModifyUserPasswordController.h"

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
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height +300);
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setNameField:nil];
    [self setOldPwdField:nil];
    [self setReNewPwdField:nil];
    [self setDNewPwdField:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)okBtClicked:(id)sender {
    if ([self checkInputStr]) {
        
    }
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
    
    if (![oldpwStr isEqualToString:@""]) {
        [self alertErrorMessage:@"原始密码不正确"];
        return NO;
    }
    return YES;
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
@end
