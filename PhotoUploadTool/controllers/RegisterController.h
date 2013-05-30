//
//  RegisterController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-22.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {REGISTER_USER = 10,MODIFY_USER}RegisterControllerType;
@interface RegisterController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pwField;
@property (weak, nonatomic) IBOutlet UITextField *rePwField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UILabel *rePwdlabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(nonatomic,assign) RegisterControllerType type;
- (IBAction)okButtonClicked:(id)sender;

@end
