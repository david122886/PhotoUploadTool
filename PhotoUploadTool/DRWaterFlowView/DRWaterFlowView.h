//
//  DRWaterFlowView.h
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRWaterFlowCell.h"
#import "DRImageData.h"
#import "EGORefreshTableHeaderView.h"
@protocol DRWaterFlowViewDelegate;
@interface DRWaterFlowView : UIScrollView<UIScrollViewDelegate,DRWaterFlowCellDelegate,EGORefreshTableHeaderDelegate>
@property(nonatomic,weak) id<DRWaterFlowViewDelegate> flowViewDelegate;
@property(nonatomic,assign) float cacheContentLenghtRate;
@property(nonatomic,strong) UIImage  *placeHolderImage;
@property(nonatomic,assign) BOOL isAbleDelete;
@property(nonatomic,assign) BOOL isloadingData;
@property(nonatomic,strong) EGORefreshTableHeaderView *refreshView;
- (DRWaterFlowCell *)dequeueReusableCellWithIdentifier: (NSString *)idStr;
- (void)unloadData;
- (void)reloadData;
-(void)loadData;
@end






@protocol DRWaterFlowViewDelegate <NSObject>
@required
//returen cell
-(DRWaterFlowCell*)flowView:(DRWaterFlowView*)flowView cellForIndex:(int)index;
//return columns
-(int)numberOfFlowViewColumns;
//return flowview width
-(int)spaceOfFlowViewCells;
//return data of cell include url
-(DRImageData*)flowView:(DRWaterFlowView*)flowView dataForIndex:(int)index;
-(int)totalDataNumbers;
//the number of one page
-(int)numberOfFlowViewOnePage;
-(void)flowView:(DRWaterFlowView*)flowView prepareLoadNextPageDataFrom:(int)fromindex to:(int)toIndex;
-(void)prepareReloadData:(DRWaterFlowView*)flowView;
-(void)flowView:(DRWaterFlowView*)flowView didSelectedIndex:(int)selectedIndex;
-(void)flowView:(DRWaterFlowView*)flowView didDeletedIndex:(int)selectedIndex;
@end