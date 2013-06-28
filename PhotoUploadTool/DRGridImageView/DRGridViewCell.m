//
//  DRGridViewCell.m
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRGridViewCell.h"
#import "AFNetworking.h"
#import "DRGridViewData.h"
#import "ImageHelper-Files.h"
#define GRIDCELL_REMOVE_WIDTH 30.0
#define GRIDCELL_REMOVE_HEIGHT 30.0
#define GRIDCELL_SPACE 2
@interface DRGridViewCell()
@property(nonatomic,strong) void (^successBlock)(DRGridViewCell *cell);
@property(nonatomic,strong) void (^errorBlock)(NSError *error);

@end
@implementation DRGridViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithReuseIdentifier:(NSString *)idStr{
    self = [super init];
    if (self) {
        self.identifier = idStr;
        self.frame = CGRectZero;
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageView];
        
        self.rmoveImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rmoveImage.image = [UIImage imageNamed:@"privatePwd_delete.png"];
        [self addSubview:self.rmoveImage];
//        self.imageView.contentMode = UIViewContentModeTop|UIViewContentModeLeft|UIViewContentModeRight;
        self.testLabel = [[UILabel alloc] init];
        self.testLabel.textColor = [UIColor blackColor];
        self.testLabel.textAlignment = UITextAlignmentCenter;
        self.testLabel.font = [UIFont systemFontOfSize:15.0];
        self.testLabel.frame = CGRectMake(0, 0, 100, 20);
        self.testLabel.backgroundColor = [UIColor clearColor];
//        [self addSubview:self.testLabel];
        DRLOG(@"initWithReuseIdentifier activityView test%@", @"");
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:self.activityView];
    }
    return self;
}

-(void)downLoadImageWithURLStr:(NSString*)url withPlaceHolderImage:(UIImage*)holderImage withSuccess:(void(^)(DRGridViewCell *cell))success failure:(void(^)(NSError *error))failure{
    if (!url) {
        return;
    }
    if (success) {
        self.successBlock = success;
    }
    if (failure) {
        self.errorBlock = failure;
    }
    [self downLoadImageWithURLStr:url withHolderImage:holderImage];
}

-(void)downLoadImageWithURLStr:(NSString *)urlStr withHolderImage:(UIImage*)holderImage{
    NSURL *url = [NSURL URLWithString:urlStr];
    //    if (![url checkResourceIsReachableAndReturnError:nil]) {
    //        if (self.errorBlock) {
    //            self.errorBlock(nil);
    //            NSLog(@"DRWaterFlowCell url error");
    //            return;
    //        }
    //    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.activityView startAnimating];
    DRGridViewCell __weak *selfCell = self;
    [self.imageView setImageWithURLRequest:request placeholderImage:holderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (selfCell) {
            [selfCell.activityView stopAnimating];
            if (!image) {
                if (selfCell.errorBlock) {
                    selfCell.errorBlock(nil);
                }
                return ;
            }
            selfCell.cachImage = [UIImage imageWithData:UIImagePNGRepresentation(image)];
            [selfCell.imageView setImage:[ImageHelper cutImage:selfCell.cachImage cutRect:selfCell.imageView.frame]];
//            [selfCell setImageData];
            if (selfCell.successBlock) {
                selfCell.successBlock(selfCell);
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (selfCell) {
            [selfCell.activityView stopAnimating];
            if (selfCell.errorBlock) {
                selfCell.errorBlock(error);
            }
        }

    }];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(GRIDCELL_SPACE, GRIDCELL_SPACE, self.frame.size.width - GRIDCELL_SPACE*2, self.frame.size.height - GRIDCELL_SPACE*2);
    self.rmoveImage.frame = CGRectMake(self.frame.size.width - GRIDCELL_REMOVE_WIDTH, 0, GRIDCELL_REMOVE_WIDTH, GRIDCELL_REMOVE_HEIGHT);
    self.activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    if (self.cachImage) {
        [self.imageView setImage:[ImageHelper cutImage:self.cachImage cutRect:self.imageView.frame]];
//        [self setImageData];
    }
}

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     [super drawRect:rect];
     CGContextRef context = UIGraphicsGetCurrentContext();
     CGContextBeginPath(context);
//     CGContextSetLineWidth(context, 2);
     CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
     float lengths[] = {2,2};
     CGContextSetLineDash(context, 0, lengths,2);
     CGContextStrokeRectWithWidth(context, self.imageView.frame, 0.5);
 // Drawing code
     
 }
 
-(void)hiddenRemoveButton:(BOOL)l{
    [self.rmoveImage setHidden:l];
}


-(void)setImageData{
    DRGridViewCell __weak *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        if (weakSelf && weakSelf.cachImage) {
            [weakSelf.imageView setImage:[ImageHelper cutImage:weakSelf.cachImage cutRect:weakSelf.imageView.frame]];
        }
    });
}
-(void)removeFromSuperview{
    [super removeFromSuperview];
    [self.imageView cancelImageRequestOperation];
    self.cachImage = nil;
}

@end
