//
//  SettingController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "SettingController.h"
#import "ModifyEmailView.h"

@interface SettingController ()

@end

@implementation SettingController

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
    self.scrollView.contentSize = (CGSize){self.view.frame.size.width,self.view.frame.size.height+300};
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"privatePwd_bg"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    [self.locationTypeSwitch setOnImage:[UIImage imageNamed:@"auto.png"]];
    [self.locationTypeSwitch setOffImage:[UIImage imageNamed:@"sd.png"]];
}

-(void)userTapGesture:(UITapGestureRecognizer*)tapGesture{
    [self.infoTextView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setEmailBt:nil];
    [self setSettingView:nil];
    [self setScrollView:nil];
    [self setUserInfoView:nil];
    [self setInfoTextView:nil];
    [self setNotificationBt:nil];
    [self setLocationBt:nil];
    [self setLocationTypeSwitch:nil];
    [super viewDidUnload];
}
- (IBAction)emailBtClicked:(id)sender {
    [ModifyEmailView defaultModifyEmailViewWithEmail:@"liuchong@yahoo.cn" WithSuccess:^(NSString *password) {
        
    } orFailure:nil orCancel:nil];
}

- (IBAction)notificationBtClicked:(id)sender {
}

- (IBAction)locationTypeChanged:(UISwitch *)sender {
}

- (IBAction)locationBtClicked:(UIButton *)sender {
    if (!self.locationTypeSwitch.on) {
        TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
        [locateView showInView:self.view];
    }
}

- (IBAction)modifyPwdBtClicked:(UIButton *)sender {
}
- (IBAction)loginOutBtClicked:(UIButton *)sender {
}

- (IBAction)cancelUserBtClicked:(UIButton *)sender {
}

#pragma mark UIActionSheetDelete
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    TSLocateView *locateView = (TSLocateView *)actionSheet;
    TSLocation *location = locateView.locate;
    [self.locationBt setTitle:[NSString stringWithFormat:@"所在地方: %@",location.city] forState:UIControlStateNormal];
}
#pragma mark --


@end
