//
//  NotificationCell.m
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.detalLabel.numberOfLines = 0;
        [self.detalLabel sizeToFit];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    CGRect detailRect = self.detailTextLabel.frame;
//    CGSize detailSize = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:18.0] constrainedToSize:CGSizeMake(detailRect.size.width, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
//    
//    self.detailTextLabel.frame = CGRectMake(detailRect.origin.x, detailRect.origin.y, detailRect.size.width, detailSize.height);
//}
@end
