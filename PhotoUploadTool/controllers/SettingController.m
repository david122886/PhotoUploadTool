//
//  SettingController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "SettingController.h"
#import "ModifyEmailView.h"
#import "UserObjDao.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "NotificationDao.h"
#import "NotificationController.h"
#import "LocatePositionManager.h"
#define NOTIFICATION_TIP @"通知列表 :"
#define EMAIL_TIP @"邮箱 :"
#define LOCATION_TIP @"所在地方 :"
@interface SettingController ()
@property(nonatomic,strong) NSArray *notificationArr;
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

-(void)setSettingViewData{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    UserObj *user = appDelegate.user;
    [self.infoTextView setText:user.userDescrible];
    [self.emailBt setTitle:[NSString stringWithFormat:@"%@ %@",EMAIL_TIP,user.userEmail==nil?@"":user.userEmail] forState:UIControlStateNormal];
    [self.notificationBt setTitle:NOTIFICATION_TIP forState:UIControlStateNormal];
    [self.locationBt setTitle:[NSString stringWithFormat:@"%@ %@",LOCATION_TIP,user.userLocation == nil?@"":user.userLocation] forState:UIControlStateNormal];
    [self.locationTypeSwitch setOn:user.locationType == LOCATION_AUTO_SET?YES:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tabBarTitleLabel.text = @"设置";
    [self.tabBarRightBt setHidden:YES];
    self.infoTextView.delegate = self;
    self.scrollView.contentSize = (CGSize){self.view.frame.size.width,self.view.frame.size.height+100};
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"privatePwd_bg"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGesture:)];
    [self.scrollView addGestureRecognizer:tapGesture];
    [self.locationTypeSwitch setOnImage:[UIImage imageNamed:@"auto.png"]];
    [self.locationTypeSwitch setOffImage:[UIImage imageNamed:@"sd.png"]];
    [self setSettingViewData];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate.user.locationType == LOCATION_AUTO_SET) {
        [self locatePosition];
    }
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
    [self setTabBarTitleLabel:nil];
    [self setTabBarRightBt:nil];
    [super viewDidUnload];
}
- (IBAction)emailBtClicked:(id)sender {
    SettingController __weak *weakSettingCtr = self;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [ModifyEmailView defaultModifyEmailViewWithEmail:appDelegate.user.userEmail WithSuccess:^(NSString *emailStr) {
        SettingController *setting = weakSettingCtr;
        [setting modifyUserEmail:emailStr];
    } orFailure:nil orCancel:nil];
}

-(void)modifyUserEmail:(NSString*)email{
    NSString __weak *WeakEmail = email;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SettingController __weak *weakSettingCtr = self;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AppDelegate __weak *weakDelegate = appDelegate;
    [UserObjDao modifyUserEmailUserObjId:appDelegate.user.userId withUserEmail:email withSuccess:^(NSString *success) {
        SettingController *setting = weakSettingCtr;
        AppDelegate *delegate = weakDelegate;
        NSString *emailStr = WeakEmail;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        delegate.user.userEmail = emailStr;
        [setting.emailBt setTitle:[NSString stringWithFormat:@"%@ %@",EMAIL_TIP,emailStr] forState:UIControlStateNormal];
    } withFailure:^(NSError *errror) {
        SettingController *setting = weakSettingCtr;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
    
}

- (IBAction)notificationBtClicked:(id)sender {
}

- (IBAction)locationTypeChanged:(UISwitch *)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (sender.isOn) {
        //LocateManager set location
        appDelegate.user.locationType = LOCATION_AUTO_SET;
        [self locatePosition];
    }else{
    //user set location by self
        appDelegate.user.locationType = LOCATION_USER_SET;
        [LocatePositionManager stopUpdate];
        TSLocateView *locateView = [[TSLocateView alloc] initWithTitle:@"定位城市" delegate:self];
        [locateView showInView:self.view];
    }
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认退出用户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = 10;
    [alert show];
}

- (IBAction)cancelUserBtClicked:(UIButton *)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"确认注销用户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = 0;
    [alert show];
}

- (IBAction)backBtClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tabBarRightBtClicked:(UIButton *)sender {
    [sender setHidden:YES];
    NSString *info = [self.infoTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([info isEqualToString:@""]) {
        return;
    }
    NSString __weak *WeakInfo = info;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SettingController __weak *weakSettingCtr = self;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AppDelegate __weak *weakDelegate = appDelegate;
    [UserObjDao modifyUserDescribleUserObjId:appDelegate.user.userId withUserDescrible:info withSuccess:^(NSString *success) {
        SettingController *setting = weakSettingCtr;
        AppDelegate *delegate = weakDelegate;
        NSString *info = WeakInfo;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        delegate.user.userDescrible = info;
    } withFailure:^(NSError *errror) {
         SettingController *setting = weakSettingCtr;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

#pragma mark UIActionSheetDelete
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        TSLocateView *locateView = (TSLocateView *)actionSheet;
        TSLocation *location = locateView.locate;
        [self updateUserLocation:location.city];
    }
    
}
#pragma mark --

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
#pragma mark UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView{
    [self.tabBarRightBt setHidden:NO];
}
#pragma mark --

#pragma mark UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 10) {//login out
        if (buttonIndex == 1) {
            //ok
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            //cancel
            
        }
    }else{//cancel user
        if (buttonIndex == 1) {
            //ok
            [self cancelUser];
        }else{
            //cancel
            
        }
    }
}
#pragma mark --

-(void)cancelUser{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SettingController __weak *weakSettingCtr = self;
    [UserObjDao destroyUserObjID:appDelegate.user.userId withSuccess:^(NSString *success) {
        SettingController *setting = weakSettingCtr;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting.navigationController popToRootViewControllerAnimated:YES];
    } withFailure:^(NSError *errror) {
        SettingController *setting = weakSettingCtr;
        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

-(void)updateUserLocation:(NSString*)locationCity{
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SettingController __weak *weakSettingCtr = self;
    NSString __weak *weakCity = locationCity;
    [UserObjDao modifyUserLocationUserObjId:appDelegate.user.userId withUserLocation:locationCity withSuccess:^(NSString *success) {
        SettingController *setting = weakSettingCtr;
        NSString *city = weakCity;
//        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting.locationBt setTitle:[NSString stringWithFormat:@"%@ %@",LOCATION_TIP,city] forState:UIControlStateNormal];
    } withFailure:^(NSError *errror) {
        SettingController *setting = weakSettingCtr;
//        [MBProgressHUD hideHUDForView:setting.view animated:YES];
        [setting alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}

-(void)downloadNotification{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    SettingController __weak *weakSettingCtr = self;
    
    [NotificationDao notificationDaoDownloadWithUserObjID:appDelegate.user.userId WithSuccess:^(NSArray *notificationArr) {
        SettingController *setting = weakSettingCtr;
        setting.notificationArr = notificationArr;
    } withFailure:nil];
}

-(void)locatePosition{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AppDelegate __weak *weakDelegate = appDelegate;
    SettingController __weak *weakSettingCtr = self;
    [LocatePositionManager locatePositionSuccess:^(NSString *locatitonName, CLLocationCoordinate2D locationg) {
        SettingController *setting = weakSettingCtr;
        AppDelegate *delegate = weakDelegate;
        delegate.user.userLocation = locatitonName;
        [setting updateUserLocation:locatitonName];
    } failure:^(NSError *error) {
        SettingController *setting = weakSettingCtr;
        [setting.locationBt setTitle:LOCATION_TIP forState:UIControlStateNormal];
        [setting.locationTypeSwitch setOn:YES];
        [setting alertErrorMessage:[error.userInfo objectForKey:@"NSLocalizedDescription"]];
    }];
}
#pragma mark property
-(NSArray *)notificationArr{
    if (!_notificationArr) {
        _notificationArr = [NSArray array];
    }
    if ([_notificationArr count] > 0) {
        [self.notificationBt setTitle:[NSString stringWithFormat:@"%@ 你有%d条通知",NOTIFICATION_TIP,[_notificationArr count]] forState:UIControlStateNormal];
    }
    return _notificationArr;
}
#pragma mark --

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (sender == self.notificationBt) {
        NotificationController *notiCtr = (NotificationController*)segue.destinationViewController;
        notiCtr.notiArr = self.notificationArr;
    }
}

@end
