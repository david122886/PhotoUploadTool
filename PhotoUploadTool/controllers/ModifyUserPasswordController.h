//
//  ModifyUserPasswordController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-29.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModifyUserPasswordController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *oldPwdField;
@property (weak, nonatomic) IBOutlet UITextField *reNewPwdField;
@property (weak, nonatomic) IBOutlet UITextField *dNewPwdField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)okBtClicked:(id)sender;

@end
