//
//  ForgotPasswordController.h
//  PhotoUploadTool
//
//  Created by david on 13-6-4.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UILabel *tabbarTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *rePwdField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIView *tabbarView;
@property (weak, nonatomic) NSString *userName;
- (IBAction)OKBtClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)backBtClicked:(id)sender;

@end
