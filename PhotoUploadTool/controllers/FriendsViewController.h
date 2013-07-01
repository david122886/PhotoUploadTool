//
//  FriendsViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-7-1.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridView.h"
#import "FriendObjDao.h"
@interface FriendsViewController : UIViewController<GridViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *bottomLeftBt;
@property (weak, nonatomic) IBOutlet UIButton *bottomRightBt;
@property (weak, nonatomic) IBOutlet UIButton *topRightBt;
- (IBAction)topRightClicked:(UIButton *)sender;
- (IBAction)bottomLeftClicked:(UIButton *)sender;
- (IBAction)bottomRightClicked:(UIButton *)sender;

@end
