//
//  DRTabBarController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicGridController.h"
#import "PrivateGridController.h"
@interface DRTabBarController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *publicItemBt;
@property (weak, nonatomic) IBOutlet UIButton *privateItemBt;
@property (weak, nonatomic) IBOutlet UIButton *settingItemBt;
@property (weak, nonatomic) IBOutlet UIView *underLine;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *drtabBarView;
@property (weak, nonatomic) IBOutlet UILabel *pwdLabel;
@property (weak, nonatomic) IBOutlet UIView *pwdCoverView;
@property (weak, nonatomic) IBOutlet UILabel *webURLLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
- (IBAction)publicItemSelected:(UIButton *)sender;
- (IBAction)privateItemSelected:(UIButton *)sender;
- (IBAction)settingItemSelected:(UIButton *)sender;
- (IBAction)modifyBtClicked:(UIButton *)sender;

@end
