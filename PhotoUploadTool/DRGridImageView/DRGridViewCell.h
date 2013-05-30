//
//  DRGridViewCell.h
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface DRGridViewCell : UIView
@property(nonatomic,strong) UILabel *testLabel;
@property(nonatomic,strong) NSString *identifier;
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,strong) UIActivityIndicatorView *activityView;
@property(nonatomic,assign) int cellIndex;
@property(nonatomic,strong) UIImageView *rmoveImage;
- (id)initWithReuseIdentifier:(NSString *)idStr;
-(void)hiddenRemoveButton:(BOOL)l;
-(void)downLoadImageWithURLStr:(NSString*)url withPlaceHolderImage:(UIImage*)holderImage withSuccess:(void(^)(DRGridViewCell *cell))success failure:(void(^)(NSError *error))failure;
@end

