//
//  DRWaterFlowCell.m
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRWaterFlowCell.h"
#import "AFNetworking.h"
#define FLOWCELL_SPACE 2.0
#define FLOWCELL_REMOVE_WIDTH 10.0
#define FLOWCELL_REMOVE_HEIGHT 10.0
@interface DRWaterFlowCell()
@property(nonatomic,strong) UIImageView *rmoveImage;
@property(nonatomic,assign) void (^successBlock)(DRWaterFlowCell *cell);
@property(nonatomic,assign) void (^errorBlock)(NSError *error);
@end
@implementation DRWaterFlowCell

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
        self.imageView.backgroundColor = [UIColor greenColor];
        [self addSubview:self.imageView];
        
        self.rmoveImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rmoveImage.backgroundColor = [UIColor blackColor];
        [self addSubview:self.rmoveImage];
        
        self.testLabel = [[UILabel alloc] init];
        self.testLabel.textColor = [UIColor blackColor];
        self.testLabel.textAlignment = UITextAlignmentCenter;
        self.testLabel.font = [UIFont systemFontOfSize:15.0];
        self.testLabel.frame = CGRectMake(0, 0, 100, 20);
        self.testLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.testLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self addSubview:self.activityView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapGestureCaptured:)];
        longTap.numberOfTouchesRequired = 1;
        [longTap requireGestureRecognizerToFail:singleTap];
        [self addGestureRecognizer:singleTap];
        [self addGestureRecognizer:longTap];

    }
    return self;
}

-(void)downLoadImageWithURLStr:(NSString*)url withPlaceHolderImage:(UIImage*)holderImage withSuccess:(void(^)(DRWaterFlowCell *cell))success failure:(void(^)(NSError *error))failure{
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
    DRWaterFlowCell __weak *selfCell = self;
    [self.imageView setImageWithURLRequest:request placeholderImage:holderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (selfCell) {
            [selfCell.activityView stopAnimating];
            [selfCell.imageView setImage:image];
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
- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    if (CGRectContainsPoint(self.rmoveImage.frame, point)) {
        if (!self.rmoveImage.isHidden && self.delegate && [self.delegate respondsToSelector:@selector(flowCell:removeButtonClickWithCellIndex:)]) {
            [self.delegate flowCell:self removeButtonClickWithCellIndex:self.imageID];
        }
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(flowCell:selectedCellAtIndex:)]) {
            [self.delegate flowCell:self selectedCellAtIndex:self.imageID];
        }
    }
}

- (void)longTapGestureCaptured:(UILongPressGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(flowCell:longPressCellAtIndex:)]) {
            [self.delegate flowCell:self longPressCellAtIndex:self.imageID];
        }
    }
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(FLOWCELL_SPACE, FLOWCELL_SPACE, self.frame.size.width - FLOWCELL_SPACE*2, self.frame.size.height - FLOWCELL_SPACE*2);
    self.rmoveImage.frame = CGRectMake(self.frame.size.width - FLOWCELL_REMOVE_WIDTH, 0, FLOWCELL_REMOVE_WIDTH, FLOWCELL_REMOVE_HEIGHT);
    self.activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)hiddenRemoveButton:(BOOL)l{
    [self.rmoveImage setHidden:l];
}

@end

@implementation FlowCellLocation
+(FlowCellLocation*)makeFlowCellLocationWithRow:(int)row withCol:(int)column withID:(int)ID withRect:(CGRect)_rect{
    FlowCellLocation *location = [[FlowCellLocation alloc] init];
    location.imageColumnIndex = column;
    location.imageRowIndex = row;
    location.imageRect = _rect;
    location.imageID = ID;
    return location;
}

-(FlowCellLocation*)copy{
    return [FlowCellLocation makeFlowCellLocationWithRow:self.imageRowIndex withCol:self.imageColumnIndex withID:self.imageID withRect:self.imageRect];
}
-(BOOL)judgeFlowCellRectContainOffset:(float)offset{
    if (CGRectContainsPoint(self.imageRect, CGPointMake(self.imageRect.origin.x + self.imageRect.size.width/2.0, offset))) {
        return YES;
    }
    return NO;
}
+(void)flowCellLocationCopyFrom:(FlowCellLocation*)from to:(FlowCellLocation*)to{
    if (!to || !from) {
        return;
    }
    to.imageColumnIndex = from.imageColumnIndex;
    to.imageRect = from.imageRect;
    to.imageRowIndex = from.imageRowIndex;
    to.imageColumnIndex = from.imageColumnIndex;
}
@end

@implementation FlowViewCritical
+(FlowViewCritical*)criticalWithColumnIndex:(int)columnIndex withTop:(FlowCritical)top withBottom:(FlowCritical)bottom{
    FlowViewCritical *crit = [[FlowViewCritical alloc] init];
    crit.topOffset = top;
    crit.bottomOffset = bottom;
    crit.columnIndex = columnIndex;
    return crit;
}
@end