//
//  FriendsViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#define QBGridViewTest 1
#pragma mark QBGridViewTest ///////

#if QBGridViewTest
#import <UIKit/UIKit.h>
#import "GridView.h"
#import "FriendObjDao.h"
#import "FriendPhotoViewController.h"
#import "TSLocateView.h"
#import "LocatePositionManager.h"
@interface FriendsViewController : UIViewController<GridViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBt;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightBt;
@property (weak, nonatomic) IBOutlet UIButton *topRightBt;
@property (weak, nonatomic) IBOutlet UILabel *notificationTipLabel;
- (IBAction)topRightClicked:(UIButton *)sender;
- (IBAction)bottomLeftClicked:(UIButton *)sender;
- (IBAction)bottomRightClicked:(UIButton *)sender;

@end

#else

#pragma mark DRGridViewTest ///////

#import <UIKit/UIKit.h>
#import "DRGridView.h"
#import "FriendObjDao.h"
#import "MWPhotoBrowser.h"
@interface FriendsViewController : UIViewController<DRGridViewDelegate,MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBt;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightBt;
@property (weak, nonatomic) IBOutlet UIButton *topRightBt;
- (IBAction)topRightClicked:(UIButton *)sender;
- (IBAction)bottomLeftClicked:(UIButton *)sender;
- (IBAction)bottomRightClicked:(UIButton *)sender;

@end

#endif