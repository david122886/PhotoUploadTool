//
//  UPLoadImageController.m
//  PhotoUploadTool
//
//  Created by david on 13-6-3.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "UPLoadImageController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+AFNetWorking.h"
#import "AppDelegate.h"
#define HIDDEN_ANIMATION_TIME .5
#define PROGRESSVIEW_HIDDEN_AFTERTIME 5
#import "AFNetworking.h"
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
    self.view.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
//    self.titleLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.6];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.progressBar.progress = 0;
	// Do any additional setup after loading the view.
    self.view.frame = (CGRect){0,-30,self.view.frame.size.width,30};
    DRLOG(@"%@", NSStringFromCGRect(self.view.frame));
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
#if 1

-(void)uploadImages:(NSArray *)assertArr withParmeters:(NSDictionary*)parmeters{
    [self.leftPhotos removeAllObjects];
    self.isUploadFinished = NO;
    self.progressBar.progress = 0.0;
    __block UPLoadImageController __weak *weakUpoadCtr = self;
    if (!assertArr || [assertArr count] < 1) {
        return;
    }
    [self viewTitleLabelUploadAnimation];
    [self setTitleLabelValueIndex:0 withTotal:[assertArr count]];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    AFHTTPClient *client = appDelegate.afhttpClient;
    NSMutableArray *mutableRequests = [NSMutableArray arrayWithCapacity:[assertArr count]];
    for (ALAsset *asset in assertArr) {
        NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"photos/upload" parameters:parmeters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            ALAssetRepresentation *representation = asset.defaultRepresentation;
            if (!representation) {
                DRLOG(@"%@", @"upload error>>>>>>>");
            }
            
             if (!representation) {
             DRLOG(@"%@", @"ALAssetRepresentation is null");
             
             }
             if (!representation.fullScreenImage) {
             DRLOG(@"%@", @"ALAssetRepresentation fullScreenImage is null");
             }
             UIImage *image = [UIImage imageWithCGImage:representation.fullScreenImage];
             NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            [formData appendPartWithFileData:imageData name:@"img" fileName:@"imag.png" mimeType:@"image/jpeg"];

        }];
        [mutableRequests addObject:request];     
        DRLOG(@"%@", request);
    }
    [client enqueueBatchOfHTTPRequestOperationsWithRequests:mutableRequests progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        if (weakUpoadCtr) {
            weakUpoadCtr.progressBar.progress = ((float)numberOfFinishedOperations)/totalNumberOfOperations;
            [weakUpoadCtr setTitleLabelValueIndex:numberOfFinishedOperations withTotal:totalNumberOfOperations];
        }
    } completionBlock:^(NSArray *operations) {
        if (weakUpoadCtr) {
            [weakUpoadCtr endUploadAnimation];
            weakUpoadCtr.isUploadFinished = YES;
            DRLOG(@"complete upload:%@", operations);
        }
    }];
}

#else
//old upload image
-(void)uploadImages:(NSArray *)assertArr withParmeters:(NSDictionary*)parmeters{
    [self.leftPhotos removeAllObjects];
    self.isUploadFinished = NO;
    self.progressBar.progress = 0.0;
    __block UPLoadImageController __weak *weakUpoadCtr = self;
    __block NSError __weak *errors = nil;
    __block int finishedCount = 0;
    __block int totalCount = [assertArr count];
    
    [self setTitleLabelValueIndex:0 withTotal:totalCount];
    for (ALAsset *asset in assertArr) {
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        if (!representation) {
            DRLOG(@"%@", @"ALAssetRepresentation is null");
            finishedCount++;
            continue;
        }
        if (!representation.fullScreenImage) {
            DRLOG(@"%@", @"ALAssetRepresentation fullScreenImage is null");
            finishedCount++;
            continue;
        }
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            //load the fullscreenImage async
            UIImage *image = [UIImage imageWithCGImage:representation.fullScreenImage];
            NSLog(@"load image success????");
            dispatch_async(dispatch_get_main_queue(), ^{
                //assign the loaded image to the view.
                NSURL *url = [NSURL URLWithString:LIUYUSERVER_URL];
                [image uploadImageWithURL:url withParameters:parmeters success:^(NSString *success) {
                    DRLOG(@"%@", success);
                    UPLoadImageController *uploadCtr  = weakUpoadCtr;
                    if (uploadCtr) {
                        uploadCtr.progressBar.progress = (float)finishedCount/totalCount;
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
                        if (assertArr) {
                            [uploadCtr.leftPhotos addObject:[assertArr objectAtIndex:finishedCount]];
                        }
                    }
                    errors = error;
                    if (finishedCount == totalCount-1) {
                        [uploadCtr endUploadAnimation];
                        uploadCtr.isUploadFinished = YES;
                        if (errors) {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"上传照片失败" delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles:nil];
                            [alert show];
                            self.progressBar.progress = 1.0;
                        }
                    }
                    finishedCount++;
                }];
            });
        });
        
        
    }
}

#endif

-(void)setTitleLabelValueIndex:(int)index withTotal:(int)total{
    self.titleLabel.text = [NSString stringWithFormat:@"上传第%d张/共%d张照片",index+1,total];
}

#pragma mark upload
-(void)endUploadAnimation{
    UPLoadImageController __weak *weakCtr = self;
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
        weakCtr.view.frame = (CGRect){0,-abs(weakCtr.view.frame.size.height),weakCtr.view.frame.size.width,abs(weakCtr.view.frame.size.height)};
    } completion:^(BOOL finished) {
        weakCtr.progressBar.progress = 0;
    }];
     DRLOG(@"%@", NSStringFromCGRect(self.view.frame));
}

-(void)viewTitleLabelUploadAnimation{
    DRLOG(@"%@", NSStringFromCGRect(self.view.frame));
    UPLoadImageController __weak *weakCtr = self;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitleLabelUploadAnimation) object:nil];
    [self performSelector:@selector(hiddenTitleLabelUploadAnimation) withObject:nil afterDelay:PROGRESSVIEW_HIDDEN_AFTERTIME];
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
       weakCtr.view.frame = (CGRect){0,0,weakCtr.view.frame.size.width,abs(weakCtr.view.frame.size.height)};
    }];
}
-(void)hiddenTitleLabelUploadAnimation{
    UPLoadImageController __weak *weakCtr = self;	
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenTitleLabelUploadAnimation) object:nil];
    [UIView animateWithDuration:HIDDEN_ANIMATION_TIME animations:^{
        weakCtr.view.frame = (CGRect){0,-abs(weakCtr.view.frame.size.height)+3,weakCtr.view.frame.size.width,abs(weakCtr.view.frame.size.height)};
    }];
    DRLOG(@"%@", NSStringFromCGRect(self.view.frame));
}
#pragma mark --
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
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
