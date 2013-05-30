//
//  NotificationCell.h
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NotificationCellDelegate;
@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *detalLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic,assign) id<NotificationCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;

@end

@protocol NotificationCellDelegate <NSObject>

-(void)notificationCell:(NotificationCell*)cell deleteAtIndexPath:(NSIndexPath*)indexPath;

@end