//
//  DRWaterFlowCell.h
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRImageData.h"
//临界值
typedef struct {CGFloat offset;int row;}FlowCritical;
@interface FlowCellLocation : NSObject
@property(nonatomic,assign) int imageRowIndex;
@property(nonatomic,assign) int imageColumnIndex;
@property(nonatomic,assign) int imageID;
@property(nonatomic,assign) CGRect imageRect;
+(void)flowCellLocationCopyFrom:(FlowCellLocation*)from to:(FlowCellLocation*)to;
+(FlowCellLocation*)makeFlowCellLocationWithRow:(int)row withCol:(int)column withID:(int)ID withRect:(CGRect)_rect;
-(BOOL)judgeFlowCellRectContainOffset:(float)offset;
-(FlowCellLocation*)copy;
@end



//
@interface  FlowViewCritical  : NSObject
@property(nonatomic,assign)FlowCritical topOffset;
@property(nonatomic,assign) FlowCritical bottomOffset;
@property(nonatomic,assign) int columnIndex;
+(FlowViewCritical*)criticalWithColumnIndex:(int)columnIndex withTop:(FlowCritical)top withBottom:(FlowCritical)bottom;
@end



@protocol DRWaterFlowCellDelegate ;
@interface DRWaterFlowCell : UIView
@property(nonatomic,assign) int imageRowIndex;
@property(nonatomic,assign) int imageColumnIndex;
@property(nonatomic,assign) int imageID;
@property(nonatomic,strong) UILabel *testLabel;
@property(nonatomic,strong) NSString *identifier;
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,weak) id<DRWaterFlowCellDelegate> delegate;
@property(nonatomic,strong) UIActivityIndicatorView *activityView;
- (id)initWithReuseIdentifier:(NSString *)idStr;
-(void)hiddenRemoveButton:(BOOL)l;
-(void)downLoadImageWithURLStr:(NSString*)url withPlaceHolderImage:(UIImage*)holderImage withSuccess:(void(^)(DRWaterFlowCell *cell))success failure:(void(^)(NSError *error))failure;
@end

@protocol DRWaterFlowCellDelegate <NSObject>
-(void)flowCell:(DRWaterFlowCell*)flowCell removeButtonClickWithCellIndex:(int)index;
-(void)flowCell:(DRWaterFlowCell*)flowCell selectedCellAtIndex:(int)index;
-(void)flowCell:(DRWaterFlowCell*)flowCell longPressCellAtIndex:(int)index;
@end