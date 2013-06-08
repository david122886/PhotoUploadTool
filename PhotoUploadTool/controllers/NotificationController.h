//
//  NotificationController.h
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationObject.h"
#import "EGORefreshTableHeaderView.h"
@interface NotificationController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
- (IBAction)backBtClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UILabel *tabbarTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
- (IBAction)tabbarEditBtClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *tabbarRightBt;
@property(nonatomic,strong) NSArray *notiArr;
@end
