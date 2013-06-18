//
//  DRGridView.h
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRGridViewCell.h"
#import "DRGridViewData.h"
#import "EGORefreshTableHeaderView.h"
#import "PrivatePwdmodifyView.h"
typedef struct {int row;float offset;}GridViewCritical;
@protocol DRGridViewDelegate;
@interface DRGridView : UIScrollView<UIScrollViewDelegate,EGORefreshTableHeaderDelegate>
@property(nonatomic,weak) id<DRGridViewDelegate> gridViewDelegate;
@property(nonatomic,strong) EGORefreshTableHeaderView *refreshView;
//@property(nonatomic,strong) EGORefreshTableHeaderView *footFreshView;
@property(nonatomic,strong) UIImage  *placeHolderImage;
@property(nonatomic,assign) BOOL isAbleDelete;
@property(nonatomic,assign) BOOL isloadingData;
@property(nonatomic,assign) BOOL isShowPrivateModifyPwdView;
@property(nonatomic,strong) PrivatePwdmodifyView *modifyPwdView;
- (DRGridViewCell *)dequeueReusableCellWithIdentifier: (NSString *)idStr;
-(void)reloadData;
-(void)jumpToCellIndex:(int)index;
-(void)deleteSelectedCellAtLoadedIndex:(int)deleteIndex;
@end

@protocol DRGridViewDelegate <NSObject>

-(int)numberOfColumns;
-(float)heightOfGridViewCell;
-(int)cacheRowsOfGridView;
-(int)numberOfEachPageRows;
-(int)numberOfPages;
-(int)totalCellCount;
-(DRGridViewCell*)gridView:(DRGridView*)gridView cellAtIndex:(int)index;
-(DRGridViewData*)gridView:(DRGridView*)gridView dataAtIndex:(int)index;
-(void)gridView:(DRGridView*)gridView modifyPrivatePwd:(UIButton*)_modifyBt;

-(void)prepareReloadData:(DRGridView*)gridView;
-(void)gridView:(DRGridView*)gridView prepareLoadNexPageIndex:(int)pageIndex;
-(void)gridView:(DRGridView*)gridView didSelectedCellIndex:(int)index;
-(void)gridView:(DRGridView*)gridView didDeleteCellIndex:(int)index;
-(void)gridView:(DRGridView*)gridView shouldDeleteCellIndex:(int)index;
-(void)prepareAddNewCellData;
@end