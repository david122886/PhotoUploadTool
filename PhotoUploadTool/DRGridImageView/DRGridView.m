//
//  DRGridView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-26.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRGridView.h"
#define GRIDVIEW_SPACE 2
@interface DRGridView()
typedef enum {SCROLL_UP,SCROLL_DOWN}ScrollViewDirection;//SCROLL_UP:scroll content down,SCROLL_DOWN:scroll content up
@property(nonatomic,assign) GridViewCritical contentTopCrit;
@property(nonatomic,assign) GridViewCritical contentBottomCrit;
@property(nonatomic,assign) int currentPageIndex;
@property(nonatomic,assign) int pageCount;
@property(nonatomic,assign) int columnCount;
@property(nonatomic,assign) float heightOfImageCell;
@property(nonatomic,assign) int cellCountOfOnePage;
@property (strong, nonatomic) NSMutableDictionary *cellPool;
@property(nonatomic,strong)NSMutableArray *loadedCells;
@property(nonatomic,assign) CGPoint lastCacheOffset;
@property(nonatomic,assign) ScrollViewDirection scrollViewDirection;
@end
@implementation DRGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.decelerationRate = UIScrollViewDecelerationRateNormal;
//        self.decelerationRate = 0.2;
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

-(void)setFlowCellIsAbleDelete:(BOOL)isDelete{
    
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[DRGridViewCell class]]) {
            DRGridViewCell *cell = (DRGridViewCell*)subView;
            if (cell.cellIndex != 0) {
                [cell hiddenRemoveButton:!isDelete];
            }
            
        }
    }
}

-(void)singleTapGestureCaptured:(UITapGestureRecognizer*)tapGesture{
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    int selectedIndex = [self getCurrentloadedArrIndex:point];
    if (selectedIndex < 0) {
        return;
    }
    DRGridViewCell *cell = [self.loadedCells objectAtIndex:selectedIndex];
    if (cell.cellIndex == 0) {
        if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(prepareAddNewCellData)]) {
            [self.gridViewDelegate prepareAddNewCellData];
        }
        return;
    }
    CGPoint cellPoint = [tapGesture locationInView:cell];
    if (CGRectContainsPoint(cell.rmoveImage.frame, cellPoint) && self.isAbleDelete) {
        //cell delete
        DRLOG(@"%@", @"deleted bt clicked");
        [self setScrollEnabled:NO];
        int loadedCellIndex = [self getCurrentloadedArrIndex:point];
        if (loadedCellIndex < 0) {
            return;
        }
//        [self deleteSelectedCellAtLoadedIndex:loadedCellIndex];
        if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:shouldDeleteCellIndex:)]) {
            [self.gridViewDelegate gridView:self shouldDeleteCellIndex:loadedCellIndex];
        }
    }else{
        //cell selected
        if (_isAbleDelete) {
            _isAbleDelete = !_isAbleDelete;
            [self setFlowCellIsAbleDelete:_isAbleDelete];
        }else{
            //selected
            if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectedCellIndex:)]) {
                [self.gridViewDelegate gridView:self didSelectedCellIndex:[self getGridViewCellIndexWithPoint:point]];
            }
        }

    }
    
    
//    NSLog(@"selected index:%d,loaded Index:%d,%@",[self getGridViewCellIndexWithPoint:point],[self getCurrentloadedArrIndex:point],NSStringFromCGPoint(point));
//    DRGridViewCell *cell = [self.loadedCells objectAtIndex:[self getCurrentloadedArrIndex:point]];
//    NSLog(@"loaded count:%d,selectedIndex:%d",[self.loadedCells count],cell.cellIndex);
}

-(void)longTapGestureCaptured:(UILongPressGestureRecognizer*)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [longPress locationInView:longPress.view];
        DRGridViewCell *cell = [self.loadedCells objectAtIndex:[self getCurrentloadedArrIndex:point]];
        if (cell.cellIndex == 0) {
            return;
        }
        if (!_isAbleDelete) {
            _isAbleDelete = !_isAbleDelete;
            [self setFlowCellIsAbleDelete:_isAbleDelete];
        }
    }
}

-(void)deleteSelectedCellAtLoadedIndex:(int)deleteIndex{
    DRGridViewCell *deletedCell = [self.loadedCells objectAtIndex:deleteIndex];
    [deletedCell removeFromSuperview];
    CGRect tempRect;
//    DRGridViewCell __weak *weakDeletedCell = deletedCell;
    float delayTime = 0.0;
    for (int index = deleteIndex+1; index < [self.loadedCells count]; index++) {
        delayTime += 0.1;
        DRGridViewCell *tempCell = [self.loadedCells objectAtIndex:index];
        tempCell.cellIndex--;
        tempCell.testLabel.text = [NSString stringWithFormat:@"%d",tempCell.cellIndex];
        tempRect = tempCell.frame;
        tempCell.frame = deletedCell.frame;
        deletedCell.frame = tempRect;
//        DRGridViewCell *weakCell = tempCell;
//        [UIView animateWithDuration:0.5 delay:delayTime options:UIViewAnimationOptionCurveLinear animations:^{
//            CGRect temp = weakCell.frame;
//            weakCell.frame = weakDeletedCell.frame;
//            weakDeletedCell.frame = temp;
//        } completion:^(BOOL finished) {
//            if (delayTime/0.1 == [self.loadedCells count] - deleteIndex-2) {
//                [self setScrollEnabled:YES];
//            }
//            
//        }];
    }
    [self.loadedCells removeObjectAtIndex:deleteIndex];
    
    if ([self.loadedCells count] <= 1) {
        self.isAbleDelete = NO;
    }
    DRGridViewCell *lastCell = [self.loadedCells lastObject];
     self.contentBottomCrit = (GridViewCritical){[self getCurrentRowIndexWithCellIndex:lastCell.cellIndex],lastCell.frame.origin.y - GRIDVIEW_SPACE};
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didDeleteCellIndex:)]) {
        [self.gridViewDelegate gridView:self didDeleteCellIndex:deleteIndex];
    }
    [self loadData];
    [self setScrollEnabled:YES];
}
-(DRGridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)idStr{
    if (0 == idStr.length) {
        return nil;
    }
    NSMutableArray *availableCells = [self.cellPool objectForKey:idStr];
    if (availableCells.count > 0) {
        DRGridViewCell *cell = [availableCells lastObject];
        [availableCells removeObject:cell];
        return cell;
    }
    return nil;
}

-(void)reloadData{
    [self unLoad];
    [self prepareLoad];
    [self loadData];
}
-(void)unLoad{
    self.currentPageIndex = 0;
    self.pageCount = 0;
    self.columnCount = 0;
    self.heightOfImageCell = 0;
    self.cellCountOfOnePage = 0;
    self.contentBottomCrit = (GridViewCritical){0,0.0};
    self.contentTopCrit = (GridViewCritical){0,0.0};
    [self.cellPool removeAllObjects];
    _cellPool = nil;
    [self.loadedCells removeAllObjects];
    _loadedCells = nil;
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DRGridViewCell class]]) {
            [subview removeFromSuperview];
        }
    }
}

-(void)prepareLoad{
    self.currentPageIndex = 0;
    self.pageCount = [self getGridViewPageCount];
    self.columnCount = [self getGridViewColumnCount];
    self.heightOfImageCell = [self getGridViewCellHeight];
    self.cellCountOfOnePage = [self getGridViewCellCountOfOnePage];
    self.contentBottomCrit = (GridViewCritical){0,0.0};
    self.contentTopCrit = (GridViewCritical){0,0.0};
}

-(void)loadData{
    @synchronized(self){
        [self addGridViewBottomCells];
        [self addGridViewTopCells];
        [self deleteGridViewTopCells];
        [self deleteGridViewBottomCells];
        [self setGridViewContentSize];
    }
    
    
}

-(void)deleteGridViewTopCells{
    while (true) {
        float topCrit = [self getCacheTopOffset];
        if (topCrit <= 0) {
            break;
        }
        if ([self.loadedCells count] <= 0) {
            break;
        }
        
        DRGridViewCell *firstCell = [self.loadedCells objectAtIndex:0];
        float firstCellHeight = firstCell.frame.origin.y + firstCell.frame.size.height;
        if (firstCellHeight > topCrit) {
            break;
        }
        DRGridViewCell *cell = [self.loadedCells objectAtIndex:0];
        [cell removeFromSuperview];
        [self addCellToReuseQueue:cell];
        [self.loadedCells removeObjectAtIndex:0];
        self.contentTopCrit = (GridViewCritical){[self getCurrentRowIndexWithCellIndex:firstCell.cellIndex],firstCell.frame.origin.y - GRIDVIEW_SPACE};
    }
}

-(void)addGridViewTopCells{
    while (true) {
        float topCrit = [self getCacheTopOffset];
        if ([self.loadedCells count] <= 0) {
            
            NSLog(@">>>>>>>>>>>>>>>>not finished function");
            break;
        }else{
            DRGridViewCell *firstCell = [self.loadedCells objectAtIndex:0];
            int startIndex = firstCell.cellIndex-1;
            if (startIndex < 0) {
                break;
            }
            if (topCrit <= 0) {
                
            }else{
                float firstCellHeight = firstCell.frame.origin.y - GRIDVIEW_SPACE;
                if (firstCellHeight < topCrit) {
                    break;
                }
            }
            DRGridViewCell *newCell = [self getCellAtIndex:startIndex];
            DRGridViewData *newData = [self getDataAtIndex:startIndex];
            newCell.cellIndex = startIndex;
            newCell.testLabel.text = [NSString stringWithFormat:@"%d",startIndex];
            newCell.frame = CGRectMake([self getCellOriginXWithCellIndex:startIndex], [self getCellOriginYWithCellIndex:startIndex], [self getGridViewCellWidth], self.heightOfImageCell);
            if (newCell.cellIndex == 0) {
                [newCell.imageView setImage:[UIImage imageNamed:@"addImage.png"]];
            }else{
                [newCell downLoadImageWithURLStr:newData.imageURLStr withPlaceHolderImage:self.placeHolderImage withSuccess:^(DRGridViewCell *cell) {
                    
                } failure:^(NSError *error) {
                    DRLOG(@"DRGridViewCell download imaage error:%@",error);
                }];
            }
            
            [newCell hiddenRemoveButton:!self.isAbleDelete];
            [self addSubview:newCell];
            [self.loadedCells insertObject:newCell atIndex:0];
            self.contentTopCrit = (GridViewCritical){[self getCurrentRowIndexWithCellIndex:startIndex],newCell.frame.origin.y - GRIDVIEW_SPACE};
        }
    }
}

-(void)deleteGridViewBottomCells{
    while (true) {
        if ([self.loadedCells count] <= 0) {
            break;
        }
        float bottomCacheOffset = [self getCacheBottomOffset];
        DRGridViewCell *lastCell = [self.loadedCells lastObject];
        if (bottomCacheOffset > lastCell.frame.origin.y - GRIDVIEW_SPACE) {
            break;
        }
        [lastCell removeFromSuperview];
        [self.loadedCells removeLastObject];
        [self addCellToReuseQueue:lastCell];
        self.contentBottomCrit = (GridViewCritical){[self getCurrentRowIndexWithCellIndex:lastCell.cellIndex],lastCell.frame.origin.y - GRIDVIEW_SPACE};
    }
}

-(void)addGridViewBottomCells{
    while (true) {
        int startIndex =[self getLoadedCellMaxIndex] ==-1?0:[self getLoadedCellMaxIndex]+1;
        if (startIndex >= [self getGridViewTotalCellCount]) {
            break;
        }
//        if (startIndex >= [self getGridViewPageCount]*[self getGridViewCellCountOfOnePage]) {
//            break;
//        }
//        if (startIndex >= (self.currentPageIndex+1)*[self getGridViewCellCountOfOnePage]) {
//            break;
//        }
        
        DRGridViewCell *cell = [self getCellAtIndex:startIndex];
        DRGridViewData *cellData = [self getDataAtIndex:startIndex];
        cell.cellIndex = startIndex;
        if (cell.cellIndex == 0) {
            [cell.imageView setImage:[UIImage imageNamed:@"addImage.png"]];
        }else{
            [cell downLoadImageWithURLStr:cellData.imageURLStr withPlaceHolderImage:self.placeHolderImage withSuccess:^(DRGridViewCell *cell) {
                
            } failure:^(NSError *error) {
                DRLOG(@"DRGridViewCell download imaage error:%@",error);
            }];
        }
        
        cell.testLabel.text = [NSString stringWithFormat:@"%d",startIndex];
        cell.frame = CGRectMake([self getCellOriginXWithCellIndex:startIndex], [self getCellOriginYWithCellIndex:startIndex], [self getGridViewCellWidth], self.heightOfImageCell);
        [cell hiddenRemoveButton:!self.isAbleDelete];
        [self addSubview:cell];
        [self.loadedCells addObject:cell];
        
        self.contentBottomCrit = (GridViewCritical){[self getCurrentRowIndexWithCellIndex:startIndex],cell.frame.origin.y + cell.frame.size.height+GRIDVIEW_SPACE};
        if ([self getCacheBottomOffset] < self.contentBottomCrit.offset) {
            break;
        }
        
        
    }
}

-(void)setGridViewContentSize{
    if (self.contentSize.height <= self.frame.size.height) {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height+1);
    }else{
        DRGridViewCell *lastCell = [self.loadedCells lastObject];
        if (lastCell.frame.origin.y + lastCell.frame.size.height > self.frame.size.height) {
            self.contentSize = CGSizeMake(self.contentSize.width, lastCell.frame.origin.y + lastCell.frame.size.height);
        }
    }
//    self.refreshView.frame = CGRectMake(0, -150, self.frame.size.width, 150);
//    [self.footFreshView setFrame:CGRectMake(0, self.contentSize.height, self.frame.size.width, 150)];
}

-(int)getLoadedCellMaxIndex{
    int maxIndex = -1;
    if ([self.loadedCells count] > 0) {
        DRGridViewCell *cell = [self.loadedCells lastObject];
         maxIndex = cell.cellIndex ;
    }
    return maxIndex;
}

-(int)getLoadedCellMinIndex{
    int minIndex = -1;
    if ([self.loadedCells count] > 0) {
        DRGridViewCell *cell = [self.loadedCells objectAtIndex:0];
        minIndex = cell.cellIndex ;
    }
    return minIndex;
}
- (void)addCellToReuseQueue: (DRGridViewCell *)cell {
    if (0 == cell.identifier.length) {
        return;
    }
    
    NSMutableArray *availableCells = [self.cellPool objectForKey:cell.identifier];
    if (0 == availableCells.count) {
        availableCells = [NSMutableArray arrayWithObject:cell];
        [self.cellPool setObject:availableCells forKey:cell.identifier];
    } else {
        [availableCells addObject:cell];
    }
}

#pragma mark Init property
-(float)getCacheTopOffset{
    int cacheRows = [self getCacheRows];
    float cacheHeight = cacheRows*(self.heightOfImageCell + GRIDVIEW_SPACE*2);
    if (self.contentOffset.y < cacheHeight) {
        return 0.0;
    }
    return self.contentOffset.y - cacheHeight;
}
-(float)getCacheBottomOffset{
    int cacheRows = [self getCacheRows];
    float cacheHeight = cacheRows*[self getRowHeight];
    return self.contentOffset.y + cacheHeight + self.frame.size.height;
}

-(int)getCurrentRowIndexWithOffset:(float)offset{
    return floor(offset/[self getRowHeight]);
}

-(int)getCurrentRowIndexWithCellIndex:(int)cellIndex{
    return cellIndex/self.columnCount;
}

-(int)getCurrentColumnIndexWithCellIndex:(int)cellIndex{
    return cellIndex%self.columnCount;
}
-(int)getCurrentColumnIndexWithOffset:(float)offset{
    return floorf(offset/[self getColumnWidth]) ;
}

-(int)getGridViewCellIndexWithPoint:(CGPoint)point{
    int rowIndex = [self getCurrentRowIndexWithOffset:point.y];
    int columnIndex = [self getCurrentColumnIndexWithOffset:point.x];
    int cellIndex = rowIndex*self.columnCount + columnIndex;
    return cellIndex < [self getGridViewTotalCellCount]?cellIndex:-1;
}
-(int)getCurrentloadedArrIndex:(CGPoint)point{
    int cellIndex = [self getGridViewCellIndexWithPoint:point];
    if (cellIndex < 0) {
        return cellIndex;
    }
    if ([self.loadedCells count] <= 0) {
        return -1;
    }
    DRGridViewCell *firstCell = [self.loadedCells objectAtIndex:0];
    return cellIndex - firstCell.cellIndex;
}
-(float)getCellOriginXWithCellIndex:(int)index{
    return [self getCurrentColumnIndexWithCellIndex:index]*[self getColumnWidth] + GRIDVIEW_SPACE;
}

-(float)getCellOriginYWithCellIndex:(int)index{
    return [self getCurrentRowIndexWithCellIndex:index]*[self getRowHeight] + GRIDVIEW_SPACE;
}

-(float)getColumnWidth{
    return self.frame.size.width/self.columnCount;
}


-(float)getRowHeight{
    return self.heightOfImageCell + GRIDVIEW_SPACE*2;
}
-(int)getCacheRows{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(cacheRowsOfGridView)]) {
        return [self.gridViewDelegate cacheRowsOfGridView];
    }
    return 0;
}
-(int)getGridViewPageCount{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(numberOfPages)]) {
        return [self.gridViewDelegate numberOfPages];
    }
    return 0;
}

-(int)getGridViewCellCountOfOnePage{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(numberOfEachPageRows)]) {
        return [self.gridViewDelegate numberOfEachPageRows];
    }
    return 0;
}

-(int)getGridViewColumnCount{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(numberOfColumns)]) {
        return [self.gridViewDelegate numberOfColumns];
    }
    return 0;
}

-(int)getGridViewTotalCellCount{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(totalCellCount)]) {
        return [self.gridViewDelegate totalCellCount];
    }
    return 0;
}

-(float)getGridViewCellHeight{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(heightOfGridViewCell)]) {
        return [self.gridViewDelegate heightOfGridViewCell];
    }
    return 0.0;
}

-(float)getGridViewCellWidth{
    return [self getColumnWidth] - GRIDVIEW_SPACE*2;
}
-(DRGridViewCell*)getCellAtIndex:(int)cellIndex{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:cellAtIndex:)]) {
        return [self.gridViewDelegate gridView:self cellAtIndex:cellIndex];
    }
    return nil;
}

-(DRGridViewData*)getDataAtIndex:(int)cellIndex{
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:dataAtIndex:)]) {
        return [self.gridViewDelegate gridView:self dataAtIndex:cellIndex];
    }
    return nil;
}

-(void)jumpToCellIndex:(int)index{

}
#pragma mark --

-(void)scrollViewScrollEnd{
    if (self.isloadingData) {
        return;
    }
    if (self.lastCacheOffset.y > self.contentOffset.y) {
        self.scrollViewDirection = SCROLL_DOWN;
    }else{
        self.scrollViewDirection = SCROLL_UP;
    }
    self.lastCacheOffset = self.contentOffset;
    [self loadData];
}

#pragma mark UIScrollDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self loadData];
    NSLog(@"scrollViewDidEndDecelerating?????????????????");
    if (self.isloadingData) {
        return;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
//    [self.footFreshView egoRefreshScrollViewDidEndDragging:scrollView];
    [self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    if (self.isloadingData) {
        return;
    }
    if (decelerate) {
        
    }else{
        NSLog(@"scrollViewDidEndDragging>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    }
    [self loadData];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    [self.footFreshView egoRefreshScrollViewDidScroll:scrollView];
    [self.refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}

#pragma mark --

#pragma mark property
-(NSMutableArray *)loadedCells{
    if (!_loadedCells) {
        _loadedCells = [NSMutableArray arrayWithCapacity:0];
    }
    return _loadedCells;
}

//-(EGORefreshTableHeaderView *)footFreshView{
//    if (!_footFreshView) {
//        _footFreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectZero];
//        _footFreshView.backgroundColor = [UIColor redColor];
//        _footFreshView.delegate = self;
//        [self addSubview:_footFreshView];
//    }
//    //    _footFreshView.frame = CGRectMake(0, self.contentSize.height, self.frame.size.width, 150);
//    return _footFreshView;
//}

-(EGORefreshTableHeaderView *)refreshView{
    if (!_refreshView) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -150, self.frame.size.width, 150)];
        _refreshView.backgroundColor = [UIColor clearColor];
        _refreshView.delegate = self;
        [self addSubview:_refreshView];
    }
    return _refreshView;
}

-(NSMutableDictionary *)cellPool{
    if (!_cellPool) {
        _cellPool = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _cellPool;
}
#pragma mark --


#pragma mark EGORefreshTableDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	self.isloadingData = YES;
    self.isAbleDelete = NO;
    [self setFlowCellIsAbleDelete:NO];
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(prepareReloadData:)]) {
        [self.gridViewDelegate prepareReloadData:self];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.isloadingData; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark --
@end
