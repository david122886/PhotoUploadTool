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
   
    self.publicController = [[PublicGridController alloc] initWithContentFrame:(CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.height}];
     self.privateController = [[PrivateGridController alloc] initWithContentFrame:(CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.height}];
    self.privateController.view.backgroundColor = [UIColor clearColor];
    self.publicController.view.backgroundColor = [UIColor clearColor];
    self.underLine.frame = CGRectMake(self.publicItemBt.frame.origin.x + self.publicItemBt.contentEdgeInsets.left, self.underLine.frame.origin.y, self.publicItemBt.frame.size.width, self.underLine.frame.size.height);
    
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    self.drtabBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarbg.png"]];
    self.pwdCoverView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    [self.pwdCoverView setHidden:YES];//hidden coverView
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *userWeb = appDelegate.user.userWebURL;
    if (userWeb) {
        NSString *webUrl = [userWeb stringByReplacingOccurrencesOfString:@"http://" withString:@""];
        NSString *ipUrl = [webUrl stringByReplacingOccurrencesOfString:@"localhost:3000" withString:LIUYUSERVER_URL];
        self.webURLLabel.text = [NSString stringWithFormat:@" 预览:%@",ipUrl];
        [self.webURLLabel addLinkToURL:[NSURL URLWithString:ipUrl] withRange:NSMakeRange(4, ipUrl.length)];
    }
    self.webURLLabel.delegate = self;
    self.pwdLabel.text = [NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,appDelegate.user.userAlbumPwd?:@""];
    [self.privateController.gridView.modifyPwdView.pwdLabel setText:[NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,appDelegate.user.userAlbumPwd?:@""]];
    self.privateController.rootController = self;
    self.publicController.rootController = self;
    [self.activityView setHidden:YES];
    [self itemSelected:self.publicItemBt withType:PUBLICITEM];
    
    [self.privateController.gridView.modifyPwdView.modifyPwdBt addTarget:self action:@selector(modifyBtClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        if (weakTabBarCtr) {
            [weakTabBarCtr modifyAlbumPassword:password];
        }
    } orFailure:nil orCancel:nil];
}

- (IBAction)backBtClicked:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        [self.publicController downloadDataISFirst:YES];
    }else
    if (type == PRIVATEITEM) {
        [self.publicItemBt setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.privateItemBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self dragDOWNCoverViewWthAnimation:YES];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dragUPCoverViewWthAnimation:) object:[NSNumber numberWithBool:YES]];
        [self performSelector:@selector(dragUPCoverViewWthAnimation:) withObject:[NSNumber numberWithBool:YES] afterDelay:15.0];
        
        [self.contentView addSubview:self.privateController.view];
        [self checkPrivatePassword];
        [self.privateController downloadDataISFirst:YES];
    }else
    {
    
    }
    self.privateController.view.userInteractionEnabled = YES;
}

-(void)checkPrivatePassword{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    NSString *tempPwd = [self.pwdLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *userAlbumPwd = @"";
    if (appDelegate.user.userAlbumPwd) {
        userAlbumPwd = [appDelegate.user.userAlbumPwd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
     DRTabBarController __weak *weakTabBarCtr = self;
//    if ([tempPwd isEqualToString:ALBUMPWD_TIP] && !self.activityView.isAnimating) {
//        [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_SETTING withAlbumPwd:userAlbumPwd  withSuccess:^(NSString *password) {
//            DRTabBarController *tabBarCtr = weakTabBarCtr;
//            [tabBarCtr modifyAlbumPassword:password];
//        } orFailure:nil orCancel:nil];
//    }
     NSString *albumPwd = [self.privateController.gridView.modifyPwdView.pwdLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([albumPwd isEqualToString:ALBUMPWD_TIP] && !self.privateController.gridView.modifyPwdView.activityView.isAnimating) {
        [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_SETTING withAlbumPwd:userAlbumPwd  withSuccess:^(NSString *password) {
            DRTabBarController *tabBarCtr = weakTabBarCtr;
            if (tabBarCtr) {
                [tabBarCtr modifyAlbumPassword:password];
            }
         
        } orFailure:nil orCancel:nil];
    }
}

-(void)modifyAlbumPassword:(NSString*)password{
    DRTabBarController __weak *weakTabBarCtr = self;
    [self.activityView startAnimating];
    [self.activityView setHidden:NO];
    self.pwdCoverView.userInteractionEnabled = NO;
    [self.privateController.gridView.modifyPwdView setUserInteractionEnabled:NO];
    [self.privateController.gridView.modifyPwdView.activityView startAnimating];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [UserObjDao modifyAlbumPwdUserObjId:appDelegate.user.userId withAlbumPwd:password withSuccess:^(NSString *success) {
        DRTabBarController *tabBarCtr = weakTabBarCtr;
        if (tabBarCtr) {
            tabBarCtr.pwdCoverView.userInteractionEnabled = YES;
            tabBarCtr.pwdLabel.text = [NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,password];
            [tabBarCtr.activityView stopAnimating];
            [tabBarCtr.activityView setHidden:YES];
            
            [tabBarCtr.privateController.gridView.modifyPwdView setUserInteractionEnabled:YES];
            [tabBarCtr.privateController.gridView.modifyPwdView.activityView stopAnimating];
            [tabBarCtr.privateController.gridView.modifyPwdView.pwdLabel setText:[NSString stringWithFormat:@"%@ %@",ALBUMPWD_TIP,password]];
        }
        
    } withFailure:^(NSError *errror) {
        DRTabBarController *tabBarCtr = weakTabBarCtr;
        if (tabBarCtr) {
            [tabBarCtr alertErrorMessage:[errror.userInfo objectForKey:@"NSLocalizedDescription"]];
            tabBarCtr.pwdCoverView.userInteractionEnabled = YES;
            [tabBarCtr.activityView stopAnimating];
            [tabBarCtr.activityView setHidden:YES];
            
            [tabBarCtr.privateController.gridView.modifyPwdView setUserInteractionEnabled:YES];
            [tabBarCtr.privateController.gridView.modifyPwdView.activityView stopAnimating];
        }
        
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


-(TTTAttributedLabel *)webURLLabel{
    if (!_webURLLabel) {
        _webURLLabel = [[TTTAttributedLabel alloc] initWithFrame:(CGRect){0,self.view.frame.size.height - 25,self.view.frame.size.width,25}];
        _webURLLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarbg.png"]];
        [_webURLLabel setFont:[UIFont systemFontOfSize:12]];
        [_webURLLabel setTextAlignment:NSTextAlignmentCenter];
        _webURLLabel.dataDetectorTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
        _webURLLabel.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
         _webURLLabel.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCTUnderlineStyleAttributeName];
        [self.view addSubview:_webURLLabel];
    }
    return _webURLLabel;
}

#pragma mark --

#pragma TTTAttributedLabelDelegate
-(void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    UIMenuController *menuCtr = [UIMenuController sharedMenuController];
    UIMenuItem *shareItem = [[UIMenuItem alloc] initWithTitle:@"预览" action:@selector(menuShareItemClicked)];
     UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(menuCopyItemClicked)];
    [menuCtr setMenuItems:@[shareItem,copyItem]];
    [self becomeFirstResponder];
    [menuCtr setTargetRect:self.webURLLabel.frame inView:self.view];
    [menuCtr setMenuVisible:YES animated:YES];    
}
#pragma mark --

#pragma mark UImenuItems method
-(void)menuShareItemClicked{
    NSLog(@"%@",self.webURLLabel.links);
    NSTextCheckingResult *result = [self.webURLLabel.links count] >0 ? [self.webURLLabel.links objectAtIndex:0]:nil;
    if (result) {
        [[UIApplication sharedApplication] openURL:result.URL];
    }
}

-(void)menuCopyItemClicked{
    NSTextCheckingResult *result = [self.webURLLabel.links count] >0 ? [self.webURLLabel.links objectAtIndex:0]:nil;
    if (result) {
        [[UIPasteboard generalPasteboard] setURL:result.URL];
    }
    
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(menuShareItemClicked) || action == @selector(menuCopyItemClicked)) {
        return YES;
    }
    return NO;
}
#pragma mark --

@end
