//
//  UPLoadImageController.m
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "UPLoadImageController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "AppDelegate.h"
#define HIDDEN_ANIMATION_TIME .5
#define PROGRESSVIEW_HIDDEN_AFTERTIME 5
@interface UPLoadImageController ()

@end

@implementation UPLoadImageController

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
    self.view.center = (CGPoint){self.view.center.x,-self.view.frame.size.height};
    self.view.backgroundColor = [UIColor clearColor];
    self.titleLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isUploadFinished) {
        [self endUploadAnimation];
    }else{
        [self hiddenTitleLabelUploadAnimation];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uploadImages:(NSArray *)assertArr{
    [self.leftPhotos removeAllObjects];
    self.isUploadFinished = NO;
    self.progressBar.progress = 0.0;
    __block UPLoadImageController __weak *weakUpoadCtr = self;
    __block NSError __weak *errors = nil;
    __block int finishedCount = 0;
    __block NSArray __weak *weakUploadImagesArr = assertArr;
    __block int totalCount = [assertArr count];
    for (ALAsset *asset in assertArr) {
        
        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        NSURL *url = [NSURL URLWithString:LIUYUSERVER_URL];
        [imageView uploadImageWithURL:url withParameters:nil success:^(NSString *success) {
            UPLoadImageController *uploadCtr  = weakUpoadCtr;
            if (uploadCtr) {
                uploadCtr.progressBar.progress = finishedCount/totalCount;
                [uploadCtr setTitleLabelValueIndex:finishedCount withTotal:totalCount];
                if (finishedCount == totalCount-1) {
                    [uploadCtr endUploadAnimation];
                    uploadCtr.isUploadFinished = YES;
                    if (errors) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"上传照片失败" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                        self.progressBar.progress = 1.0;
                    }
                }
            }
            finishedCount++;
        } error:^(NSError *error) {
            UPLoadImageController *uploadCtr  = weakUpoadCtr;
            if (uploadCtr) {
                if (weakUploadImagesArr) {
                    [uploadCtr.leftPhotos addObject:[weakUploadImagesArr objectAtIndex:finishedCount]];
                }
            }
            errors = error;
            finishedCount++;
        }];
    }
}

-(void)setTitleLabelValueIndex:(int)index withTotal:(int)total{
    self.titleLabel.text = [NSString stringWithFormat:@"上传%d/%d张照片",index,total];
}

#pragma mark upload
-(void)endUploadAnimation{
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
        self.view.center = (CGPoint){self.view.center.x,-self.view.frame.size.height};
    }];
}

-(void)viewTitleLabelUploadAnimation{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitleLabelUploadAnimation) object:nil];
    [self performSelector:@selector(hiddenTitleLabelUploadAnimation) withObject:nil afterDelay:PROGRESSVIEW_HIDDEN_AFTERTIME];
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
        self.view.center = (CGPoint){self.view.center.x,[self getCenterY]*2+5};
    }];
}
-(void)hiddenTitleLabelUploadAnimation{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitleLabelUploadAnimation) object:nil];
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
        self.view.center = (CGPoint){self.view.center.x,-[self getCenterY]};
    }];
}
#pragma mark --
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
}

-(float)getCenterY{
    return self.titleLabel.frame.size.height/2-5;//(self.titleLabel.frame.size.height+ self.progressBar.frame.size.height)/2;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.isUploadFinished) {
        [self hiddenTitleLabelUploadAnimation];
    }
}

#pragma mark property
-(NSMutableArray *)leftPhotos{
    if (!_leftPhotos) {
        _leftPhotos = [NSMutableArray array];
    }
    return _leftPhotos;
}
#pragma mark --
@end
