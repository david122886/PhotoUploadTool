//
//  SettingController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSLocateView.h"
@interface SettingController : UIViewController<UIActionSheetDelegate,UITextViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIView *userInfoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *settingView;
@property (weak, nonatomic) IBOutlet UIButton *emailBt;
@property (weak, nonatomic) IBOutlet UIButton *notificationBt;
@property (weak, nonatomic) IBOutlet UIButton *tabBarRightBt;
@property (weak, nonatomic) IBOutlet UILabel *tabBarTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationBt;
- (IBAction)emailBtClicked:(id)sender;
- (IBAction)notificationBtClicked:(id)sender;
- (IBAction)locationTypeChanged:(UISwitch *)sender;
- (IBAction)locationBtClicked:(UIButton *)sender;
- (IBAction)modifyPwdBtClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *locationTypeSwitch;
- (IBAction)loginOutBtClicked:(UIButton *)sender;
- (IBAction)cancelUserBtClicked:(UIButton *)sender;
- (IBAction)backBtClicked:(UIButton *)sender;
- (IBAction)tabBarRightBtClicked:(UIButton *)sender;

@end
