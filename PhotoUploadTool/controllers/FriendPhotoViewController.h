//
//  FriendPhotoViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-7-11.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "DRImageTool.h"
#import "AppDelegate.h"
#import "DRImageObj.h"
#import "MWPhotoBrowser.h"
#import "AppDelegate.h"
#import "FriendObjDao.h"
@interface FriendPhotoViewController : UIViewController<GridViewDelegate,MWPhotoBrowserDelegate>
@property (nonatomic,strong) NSString *friendID;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,assign) BOOL isLocked;
- (IBAction)backBtClicked:(UIButton *)sender;
- (void)downloadFriendsPhotosWithImageType:(ImageDataType)type;
@end
