//
//  DRTabBarController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRTabBarController.h"
#import "SettingPrivatePwdView.h"
typedef enum {PUBLICITEM = 10,PRIVATEITEM,SETTINGITEM}TabBarItem;
@interface DRTabBarController ()
@property(nonatomic,strong) PublicGridController *publicController;
@property(nonatomic,strong) PrivateGridController *privateController;
@property(nonatomic,strong) NSString *privatePwdTip;
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
    [super viewDidLoad];
    self.privatePwdTip = @"相册密码 :"; 
    self.publicController = [[PublicGridController alloc] init];
    self.privateController = [[PrivateGridController alloc] init];
    self.privateController.view.backgroundColor = [UIColor clearColor];
    self.publicController.view.backgroundColor = [UIColor clearColor];
    self.privateController.view.frame = (CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.width};
    self.publicController.view.frame = (CGRect){0,0,self.contentView.frame.size.width,self.contentView.frame.size.width};
    
    [self itemSelected:self.publicItemBt withType:PUBLICITEM];
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"_bg.png"]];
    self.drtabBarView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbarbg.png"]];
    self.pwdCoverView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8];
    self.pwdLabel.text = self.privatePwdTip;
	// Do any additional setup after loading the view.
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
    [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_MODIFY withSuccess:^(NSString *password) {
        self.pwdLabel.text = password;
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
}

-(void)checkPrivatePassword{
    if ([[self.pwdLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:self.privatePwdTip]) {
        [SettingPrivatePwdView defaultSettingPrivatePwdViewType:PRIVATEPWDVIEW_SETTING withSuccess:^(NSString *password) {
            self.pwdLabel.text = password;
        } orFailure:nil orCancel:nil];
    }
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
@end
