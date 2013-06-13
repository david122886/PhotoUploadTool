//
//  DRTabBarController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRTabBarController.h"
#import "SettingPrivatePwdView.h"
#import "AppDelegate.h"
#import "UserObjDao.h"
#import "AppDelegate.h"
#define ALBUMPWD_TIP @"相册密码 :"
typedef enum {PUBLICITEM = 10,PRIVATEITEM,SETTINGITEM}TabBarItem;
@interface DRTabBarController ()
@property(nonatomic,strong) PublicGridController *publicController;
@property(nonatomic,strong) PrivateGridController *privateController;
@end

@implementation DRTabBarController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDataNotification) name:TABBAR_DOWNLOADDATA_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDataNotificationFinished) name:TABBAR_DOWNLOADDATA_NOTIFICATION_OK object:nil];
    [super viewDidLoad];
   
    self.publicController = [[PublicGridController alloc] init];
     self.privateController = [[PrivateGridController alloc] init];
    self.privateController.view.backgroundColor = [UIColor clearColor];
    self.publicController.view.backgroundColor = [UIColor clearColor];
    self.privateController.view.frame = (CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.height};
    self.publicController.view.frame = (CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.height};
    self.underLine.frame = CGRectMake(self.publicItemBt.frame.origin.x + self.publicItemBt.contentEdgeInsets.left, self.underLine.frame.origin.y, self.publicItemBt.frame.size.width, self.underLine.frame.size.height);
    
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    self.drtabBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarbg.png"]];
    self.pwdCoverView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.webURLLabel.text = appDelegate.user.userWebURL==nil?@"":appDelegate.user.userWebURL;
    self.pwdLabel.text = [NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,appDelegate.user.userAlbumPwd?:@""];
    self.privateController.rootController = self;
    self.publicController.rootController = self;
    [self.activityView setHidden:YES];
    [self itemSelected:self.publicItemBt withType:PUBLICITEM];
    
    	// Do any additional setup after loading the view.
}

-(void)downloadDataNotification{
//    [self.drtabBarView setUserInteractionEnabled:NO];
    [self.pwdCoverView setUserInteractionEnabled:NO];
}

-(void)downloadDataNotificationFinished{
    [self.drtabBarView setUserInteractionEnabled:YES];
    [self.pwdCoverView setUserInteractionEnabled:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPublicItemBt:nil];
    [self setPrivateItemBt:nil];
    [self setSettingItemBt:nil];
    [self setUnderLine:nil];
    [self setContentView:nil];
    [self setPwdLabel:nil];
    [self setPwdCoverView:nil];
    [self setDrtabBarView:nil];
    self.publicController = nil;
    self.privateController = nil;
    [self setWebURLLabel:nil];
    [self setActivityView:nil];
    [super viewDidUnload];
}
- (IBAction)publicItemSelected:(UIButton *)sender {
    [self itemSelected:sender withType:PUBLICITEM];
}

- (IBAction)privateItemSelected:(UIButton *)sender {
    [self itemSelected:sender withType:PRIVATEITEM];
}

- (IBAction)settingItemSelected:(UIButton *)sender {
    
}

- (IBAction)modifyBtClicked:(UIButton *)sender {
    DRTabBarController __weak *weakTabBarCtr = self;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_MODIFY withAlbumPwd:appDelegate.user.userAlbumPwd==nil?@"":appDelegate.user.userAlbumPwd withSuccess:^(NSString *password) {
        DRTabBarController *tabBarCtr = weakTabBarCtr;
        [tabBarCtr modifyAlbumPassword:password];
    } orFailure:nil orCancel:nil];
}

-(void)itemSelected:(UIButton*)item withType:(TabBarItem)type{
    [UIView animateWithDuration:0.5 animations:^{
        self.underLine.frame = CGRectMake(item.frame.origin.x + item.contentEdgeInsets.left, self.underLine.frame.origin.y, item.frame.size.width, self.underLine.frame.size.height);
    }];
    
    for (UIView *subView in [self.contentView subviews]) {
        [subView removeFromSuperview];
    }
    
    if (type == PUBLICITEM) {
        [self.publicItemBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.privateItemBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self dragUPCoverViewWthAnimation:NO];
//        CGPoint center = self.publicController.view.center;
//        self.publicController.view.center = (CGPoint){-center.x,center.y};
//        [self.contentView addSubview:self.publicController.view];
//        [UIView animateWithDuration:0.5 animations:^{
//            self.publicController.view.center = center;
//        }];
        [self.contentView addSubview:self.publicController.view];
    }else
    if (type == PRIVATEITEM) {
        [self.publicItemBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.privateItemBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self dragDOWNCoverViewWthAnimation:YES];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dragUPCoverViewWthAnimation:) object:[NSNumber numberWithBool:YES]];
        [self performSelector:@selector(dragUPCoverViewWthAnimation:) withObject:[NSNumber numberWithBool:YES] afterDelay:15.0];
        
        [self.contentView addSubview:self.privateController.view];
        [self checkPrivatePassword];
    }else
    {
    
    }
    self.privateController.view.userInteractionEnabled = YES;
}

-(void)checkPrivatePassword{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *tempPwd = [self.pwdLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userAlbumPwd = @"";
    if (appDelegate.user.userAlbumPwd) {
        userAlbumPwd = [appDelegate.user.userAlbumPwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
     DRTabBarController __weak *weakTabBarCtr = self;
    if ([tempPwd isEqualToString:ALBUMPWD_TIP] && !self.activityView.isAnimating) {
        [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_SETTING withAlbumPwd:userAlbumPwd  withSuccess:^(NSString *password) {
            DRTabBarController *tabBarCtr = weakTabBarCtr;
            [tabBarCtr modifyAlbumPassword:password];
        } orFailure:nil orCancel:nil];
    }
}

-(void)modifyAlbumPassword:(NSString*)password{
    DRTabBarController __weak *weakTabBarCtr = self;
    [self.activityView startAnimating];
    [self.activityView setHidden:NO];
    self.pwdCoverView.userInteractionEnabled = NO;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [UserObjDao modifyAlbumPwdUserObjId:appDelegate.user.userId withAlbumPwd:password withSuccess:^(NSString *success) {
        DRTabBarController *tabBarCtr = weakTabBarCtr;
        tabBarCtr.pwdCoverView.userInteractionEnabled = YES;
        tabBarCtr.pwdLabel.text = [NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,password];
        [tabBarCtr.activityView stopAnimating];
        [tabBarCtr.activityView setHidden:YES];
    } withFailure:^(NSError *errror) {
        DRTabBarController *tabBarCtr = weakTabBarCtr;
        [tabBarCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
        tabBarCtr.pwdCoverView.userInteractionEnabled = YES;
        [tabBarCtr.activityView stopAnimating];
        [tabBarCtr.activityView setHidden:YES];
    }];
    
}

-(void)dragUPCoverViewWthAnimation:(BOOL)animation{
    
    
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pwdCoverView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        }];
    }else{
        self.pwdCoverView.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    }
}

-(void)dragDOWNCoverViewWthAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.5 animations:^{
            self.pwdCoverView.frame = CGRectMake(0, 44, self.view.frame.size.width, 40);
        }];
    }else{
        self.pwdCoverView.frame = CGRectMake(0, 44, self.view.frame.size.width, 40);
    }
    
}

-(void)alertErrorMessage:(NSString*)mes{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:mes delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark property

#pragma mark --
@end
