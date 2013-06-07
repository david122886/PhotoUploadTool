//
//  UPLoadImageController.h
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UPLoadImageController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property(nonatomic,assign) BOOL isUploadFinished;
@property(nonatomic,strong) NSMutableArray *leftPhotos;
-(void)uploadImages:(NSArray *)assertArr withParmeters:(NSDictionary*)parmeters;
-(void)viewTitleLabelUploadAnimation;
@end
