//
//  LoginInController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginInController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *typeBackground;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UIButton *forgotPwdBt;
@property (weak, nonatomic) IBOutlet UIButton *registerBt;
@property (weak, nonatomic) IBOutlet UITextField *passwdField;
- (IBAction)LoginBtClicked:(id)sender;
- (IBAction)registerBtClicked:(id)sender;
- (IBAction)forgotPasswordClicked:(id)sender;
- (IBAction)backBtClicked:(id)sender;

@end
