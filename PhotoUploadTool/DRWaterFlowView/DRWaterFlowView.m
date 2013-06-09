//
//  DRWaterFlowView.m
//  PhotoUploadTool
//
//  Created by david on 13-5-17.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "DRWaterFlowView.h"
#define FLOWVIEWCELL_SPACE 10
#define SCROLLVIEW_CONTENT_PER_HEIGHT 20
#define CACHECONTENT_LENGHT_RATE 2.0
typedef struct {float topOffset;float bottomOffset;}DRFlowCacheOffset;

typedef enum {SCROLL_UP,SCROLL_DOWN}ScrollViewDirection;//SCROLL_UP:scroll content down,SCROLL_DOWN:scroll content up
@interface DRWaterFlowView ()
//current loaded cells,key:index,value:cell
@property (strong, nonatomic) NSMutableDictionary *loadedCells;
//store column location arrary 
@property(nonatomic,strong) NSMutableArray *totalCellLocation;
//store FlowViewCritical of each column
@property(nonatomic,strong) NSMutableArray *totalColumnOffset;
@property (strong, nonatomic) NSMutableDictionary *cellPool;
@property(nonatomic,assign) int columnCount;
@property(nonatomic,assign) int totalCellsCount;
@property(nonatomic,assign) int currentPageIndex;
@property(nonatomic,assign) int loadedCellMaxIndex;
@property(nonatomic,assign) float cellWidth;
@property(nonatomic,assign) float cellSpace;
@property(nonatomic,assign) int cellsCountForOnePage;
@property(nonatomic,assign) CGPoint lastCacheOffset;
@property(nonatomic,assign) ScrollViewDirection scrollViewDirection;
@end

@implementation DRWaterFlowView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        [self setDecelerationRate:UIScrollViewDecelerationRateNormal];
    }
    return self;
}



-(DRWaterFlowCell *)dequeueReusableCellWithIdentifier:(NSString *)idStr{
    if (0 == idStr.length) {
        return nil;
    }
    NSMutableArray *availableCells = [self.cellPool objectForKey:idStr];
    if (availableCells.count > 0) {
        DRWaterFlowCell *cell = [availableCells lastObject];
        [availableCells removeObject:cell];
        return cell;
    }
    return nil;
}
-(void)reloadData{
    [self unloadData];
    [self prepareLoadData];
    [self loadData];
}

-(void)loadData{
    [self reSetCurrentPageIndex];
    DRFlowCacheOffset cacheOffset = [self getFlowCacheOffset];
    FlowViewCritical *BottomCrit = [self.totalColumnOffset objectAtIndex:[self getColumnIndexForBottomMinOffset]];
    if (self.scrollViewDirection == SCROLL_UP) {
        //add bottom
        if (BottomCrit.bottomOffset.offset <  cacheOffset.bottomOffset) {
            //add cell into scroll view(columnContentCrit.bottomOffset.offset ---cacheOffset.bottomOffset)
            int startIndex = [self getCellMaxIndexForBottomCritical];
            if (startIndex != 0) {
                startIndex += 1;
            }
            NSLog(@"max lodaded index:%d",startIndex);
            [self ScrollViewBottomAddCellsWithStartIndex:startIndex withMaxOffset:cacheOffset.bottomOffset];
        }
    }else{
        //delete bottom
        if (BottomCrit.bottomOffset.offset >  cacheOffset.bottomOffset) {
            //delete from scroll view(columnContentCrit.bottomOffset.offset ----- cacheOffset.bottomOffset)
            
            [self ScrollViewBottomDeleteCells];
        }
    }
    
    [self setScrollViewContentSize];
    
    
    return;
    for (int columnIndex = 0; columnIndex < self.columnCount; columnIndex++) {
        FlowViewCritical *columnContentCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        
        //add bottom
        if (columnContentCrit.bottomOffset.offset <  cacheOffset.bottomOffset) {
            //add cell into scroll view(columnContentCrit.bottomOffset.offset ---cacheOffset.bottomOffset)
        }
        if (columnContentCrit.bottomOffset.offset < cacheOffset.topOffset) {
            //add cell into scroll view(columnContentCrit.bottomOffset.offset ---cacheOffset.bottomOffset)
        }
        
        //delete bottom
        if (columnContentCrit.bottomOffset.offset >  cacheOffset.bottomOffset) {
            //delete from scroll view(columnContentCrit.bottomOffset.offset ----- cacheOffset.bottomOffset)
            
        }
        
        //top add
        if (columnContentCrit.topOffset.offset <  cacheOffset.topOffset && cacheOffset.topOffset > 0) {
            //add cell into scroll view(columnContentCrit.topOffset.offset ---  cacheOffset.topOffset)
        }
        
        //top delete
        if (columnContentCrit.topOffset.offset >  cacheOffset.topOffset) {
            //delete from scroll view(columnContentCrit.topOffset.offset ----  cacheOffset.topOffset)
            
        }
        
    }
    [self setScrollViewContentSize];
}

-(void)ScrollViewBottomDeleteCells{
    [self setScrollEnabled:NO];
    DRFlowCacheOffset cacheOffset = [self getFlowCacheOffset];
    for (int columnIndex = 0; columnIndex < [self.totalCellLocation count]; columnIndex++) {
        NSArray *columnCellArr = [self.totalCellLocation objectAtIndex:columnIndex];
        if (!columnCellArr) {
            continue;
        }
        FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:columnIndex];
        
        FlowCellLocation *startColumnLocation = [self getCellLocatitonForMaxOffset:cacheOffset.bottomOffset withColumnIndex:columnIndex withStartRowIndex:0 withEndRowIndex:crit.bottomOffset.row-1];
        NSLog(@"start deleted row:%d,col:%d,row count:%d",startColumnLocation.imageRowIndex,startColumnLocation.imageColumnIndex,[columnCellArr count]);
        for (int rowIndex = [columnCellArr count] - 1; rowIndex > startColumnLocation.imageRowIndex; rowIndex--) {
            FlowCellLocation *location = [columnCellArr objectAtIndex:rowIndex];
            DRWaterFlowCell *cell = [self.loadedCells objectForKey:[NSNumber numberWithInt:location.imageID]];
            [cell removeFromSuperview];
            
            //modify totalColumnOffset arr
            NSLog(@"start deleted row:%d,col:%d",rowIndex,startColumnLocation.imageColumnIndex);
            FlowCritical newCrit;
            newCrit.offset = cell.frame.origin.y - self.cellSpace;
            newCrit.row = cell.imageRowIndex;
            crit.bottomOffset = newCrit;
            
            [self addCellToReuseQueue:cell];
            [self.loadedCells removeObjectForKey:[NSNumber numberWithInt:location.imageID]];
        }
    }
    [self setScrollEnabled:YES];
}

-(void)ScrollViewBottomAddCellsWithStartIndex:(int)startIndex withMaxOffset:(float)maxOffset{
    for (int index = startIndex; index <= [self getMaxCellIndexForPageIndex:self.currentPageIndex]; index++) {
        if (index < self.columnCount){
            [self loadDataWithIndex:index withColoumn:index%self.columnCount];
        }else{
            [self loadDataWithIndex:index withColoumn:[self getColumnIndexForBottomMinOffset]];
        }
        FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:[self getColumnIndexForBottomMinOffset]];
        if (crit.bottomOffset.offset > maxOffset) {
            break;
        }
    }
}

-(void)scrollViewRemoveSelectedCell:(DRWaterFlowCell*)cell{
    if (!cell) {
        return;
    }
    NSLog(@" start move cell row index:%d,col:%d,index:%d",cell.imageRowIndex,cell.imageColumnIndex,cell.imageID);
    NSMutableArray *columnCellArr = [self.totalCellLocation objectAtIndex:cell.imageColumnIndex];
    FlowCellLocation *removeLocation = [columnCellArr objectAtIndex:cell.imageRowIndex];
    float removeHeight = removeLocation.imageRect.size.height + self.cellSpace*2.0;
    for (int rowIndex = cell.imageRowIndex+1; rowIndex < [columnCellArr count]; rowIndex++) {
         NSLog(@"move column row count:%d ,move index:%d",[columnCellArr count],rowIndex);
        FlowCellLocation *tempLocation = [columnCellArr objectAtIndex:rowIndex];
        CGRect tempRect = tempLocation.imageRect;
        tempLocation.imageRowIndex = tempLocation.imageRowIndex -1;
        tempLocation.imageRect = CGRectMake(tempRect.origin.x, tempRect.origin.y - removeHeight, tempRect.size.width, tempRect.size.height);
        DRWaterFlowCell *tempCell = [self.loadedCells objectForKey:[NSNumber numberWithInt:tempLocation.imageID]];
        if (tempCell) {
            tempCell.frame = tempLocation.imageRect;
            tempCell.imageRowIndex = tempLocation.imageRowIndex;
        }
    }
    
    [columnCellArr removeObjectAtIndex:cell.imageRowIndex];
    
    [self.loadedCells removeObjectForKey:[NSNumber numberWithInt:cell.imageID]];
//    [self diseaseLoadedCellsDicStartIndex:cell.imageID];
    
    FlowCellLocation *lastLocation = [columnCellArr lastObject];
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:cell.imageColumnIndex];
    FlowCritical newCrit;
    if (lastLocation) {
        newCrit.offset = lastLocation.imageRect.origin.y +lastLocation.imageRect.size.height + self.cellSpace;
        newCrit.row = crit.bottomOffset.row - 1;
        crit.bottomOffset = newCrit;
    }else{
        newCrit.offset = 0;
        newCrit.row = 0;
        crit.bottomOffset = newCrit;
    }
     NSLog(@"new critical row:%d ,offset:%f",crit.bottomOffset.row,crit.bottomOffset.offset);
    
    [cell removeFromSuperview];
    [self exchangeLastRowCellPositionForColumns:cell.imageColumnIndex];
    [self reSetCurrentPageIndex];
    [self setScrollViewContentSize];
}

//set max offset into min offset
-(void)exchangeLastRowCellPositionForColumns:(int)deletedColumnIndex{
    int columnIndexOfMinOffset = -1;
    int columnIndexOfMaxOffset = -1;
    float minOffset = 0;
    float maxOffset = 0;
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        FlowViewCritical *columnCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        if (columnIndex == 0) {
            columnIndexOfMaxOffset = columnIndex;
            maxOffset = columnCrit.bottomOffset.offset; 
        }else{
            if (columnCrit.bottomOffset.offset > maxOffset) {
                maxOffset = columnCrit.bottomOffset.offset;
                columnIndexOfMaxOffset = columnIndex;
            }
        }
    }
    
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        FlowViewCritical *columnCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        if (columnIndex == 0) {
            columnIndexOfMinOffset = columnIndex;
            minOffset = columnCrit.bottomOffset.offset;
        }else
        if (columnCrit.bottomOffset.offset < minOffset) {
            columnIndexOfMinOffset = columnIndex;
            minOffset = columnCrit.bottomOffset.offset;
        }
//        NSArray *columnCellArr = [self.totalCellLocation objectAtIndex:columnIndex];
//        if (columnCrit.bottomOffset.row < 1) {
//            columnIndexOfMinOffset = columnIndex;
//            break;
//        }
//        if ([columnCellArr count] < 1) {
//            columnIndexOfMinOffset = columnIndex;
//            break;
//        }
//        int tempRow = columnCrit.bottomOffset.row-1<0?0:columnCrit.bottomOffset.row-1;
//        FlowCellLocation *tempLocation = [columnCellArr objectAtIndex:tempRow];
//        if (columnIndex == 0) {
//            minOffset =  tempLocation.imageRect.origin.y;
//            columnIndexOfMinOffset = columnIndex;
//        }else{
//            if (tempLocation.imageRect.origin.y < minOffset) {
//                minOffset = tempLocation.imageRect.origin.y;
//                columnIndexOfMinOffset = columnIndex;
//            }
//        }
    }
    
    NSLog(@"columnIndexOfMinOffset:%d,columnIndexOfMaxOffset:%d",columnIndexOfMinOffset,columnIndexOfMaxOffset);
    [self exchangelastRowCellpositionFromColumnIndex:columnIndexOfMaxOffset toColumnIndex:columnIndexOfMinOffset];
}

-(void)exchangelastRowCellpositionFromColumnIndex:(int)startColumnIndex toColumnIndex:(int)endColumnIndex{
    if (startColumnIndex == endColumnIndex) {
        return;
    }
    FlowViewCritical *startCrit = [self.totalColumnOffset objectAtIndex:startColumnIndex];
    FlowViewCritical *endCrit = [self.totalColumnOffset objectAtIndex:endColumnIndex];
    if (startCrit.bottomOffset.row < 1 && endCrit.bottomOffset.row < 1) {
        return;
    }
    FlowCellLocation *startLocation = nil;
    FlowCellLocation *endLocation = nil;
    if ([[self.totalCellLocation objectAtIndex:startColumnIndex] count] > 0) {
        startLocation = [[self.totalCellLocation objectAtIndex:startColumnIndex] objectAtIndex:startCrit.bottomOffset.row-1];
    }
    
    if ([[self.totalCellLocation objectAtIndex:endColumnIndex] count] > 0) {
        endLocation = [[self.totalCellLocation objectAtIndex:endColumnIndex] objectAtIndex:endCrit.bottomOffset.row-1];
    }
    DRWaterFlowCell *startCell = nil;
    DRWaterFlowCell *endCell = nil;
    if (startLocation && !endLocation) {
        startCrit.bottomOffset = (FlowCritical){startLocation.imageRect.origin.y - self.cellSpace,startLocation.imageRowIndex};
        
        startLocation.imageColumnIndex = endColumnIndex;
        startLocation.imageRowIndex = 0;
        CGRect startRect = startLocation.imageRect;
        startLocation.imageRect = CGRectMake([self getCellOriginXWithCloumnIndex:endColumnIndex], self.cellSpace, startRect.size.width, startRect.size.height);
        
        endCrit.bottomOffset = (FlowCritical){startLocation.imageRect.origin.y + startLocation.imageRect.size.height + self.cellSpace,1};
        
        startCell = [self.loadedCells objectForKey:[NSNumber numberWithInt:startLocation.imageID]];
        startCell.imageColumnIndex = startLocation.imageColumnIndex;
        startCell.imageRowIndex = startLocation.imageRowIndex;
        startCell.frame = startLocation.imageRect;
        
        [[self.totalCellLocation objectAtIndex:endColumnIndex] addObject:startLocation];
        [[self.totalCellLocation objectAtIndex:startColumnIndex] removeObjectAtIndex:startCrit.bottomOffset.row];
        
    }else
    if((!startLocation && endLocation)){
        endCrit.bottomOffset = (FlowCritical){endLocation.imageRect.origin.y - self.cellSpace,endLocation.imageRowIndex};
        
        endLocation.imageColumnIndex = startColumnIndex;
        endLocation.imageRowIndex = 0;
        CGRect endRect = endLocation.imageRect;
        endLocation.imageRect = CGRectMake([self getCellOriginXWithCloumnIndex:startColumnIndex], self.cellSpace, endRect.size.width, endRect.size.height);
        
        startCrit.bottomOffset = (FlowCritical){endLocation.imageRect.origin.y + endLocation.imageRect.size.height + self.cellSpace,1};
        
        endCell = [self.loadedCells objectForKey:[NSNumber numberWithInt:endLocation.imageID]];
        endCell.imageColumnIndex = endLocation.imageColumnIndex;
        endCell.imageRowIndex = endLocation.imageRowIndex;
        endCell.frame = endLocation.imageRect;
        
        [[self.totalCellLocation objectAtIndex:startColumnIndex] addObject:endLocation];
        [[self.totalCellLocation objectAtIndex:endColumnIndex] removeObjectAtIndex:endCrit.bottomOffset.row];
    }else{
        
        startCrit.bottomOffset = (FlowCritical){startLocation.imageRect.origin.y - self.cellSpace,startLocation.imageRowIndex};
        
        
        startLocation.imageRowIndex = endLocation.imageRowIndex +1;
        startLocation.imageColumnIndex = endColumnIndex;
        startLocation.imageRect = CGRectMake(endLocation.imageRect.origin.x, [self getCellOriginYWithCloumnIndex:endColumnIndex], startLocation.imageRect.size.width, startLocation.imageRect.size.height);
        
        
        endCrit.bottomOffset = (FlowCritical){endCrit.bottomOffset.offset + startLocation.imageRect.size.height + self.cellSpace,startLocation.imageRowIndex+1};
        
        startCell = [self.loadedCells objectForKey:[NSNumber numberWithInt:startLocation.imageID]];
        startCell.imageColumnIndex = startLocation.imageColumnIndex;
        startCell.imageRowIndex = startLocation.imageRowIndex;
        startCell.frame = startLocation.imageRect;
        
        [[self.totalCellLocation objectAtIndex:endColumnIndex] addObject:startLocation];
        [[self.totalCellLocation objectAtIndex:startColumnIndex] removeObjectAtIndex:startCrit.bottomOffset.row];
        
    }
    
    self.contentSize = CGSizeMake(self.frame.size.width, [self getBottomMaxOffset]);
    self.lastCacheOffset = self.contentOffset;
}

//所有删除的cell下面的cell index减1
-(void)diseaseLoadedCellsDicStartIndex:(int)startIndex{
    if ([self.loadedCells count] > startIndex) {
        NSMutableDictionary *newLoadedCells = [NSMutableDictionary dictionaryWithCapacity:[self.loadedCells count]];
        NSArray *allKeys = [self.loadedCells allKeys];
        NSArray *sortKeys = [allKeys sortedArrayUsingSelector:@selector(compare:)];
        for (NSNumber *number in sortKeys) {
            if (number.intValue < startIndex) {
                [newLoadedCells setObject:[self.loadedCells objectForKey:number] forKey:number];
            }else{
                [newLoadedCells setObject:[self.loadedCells objectForKey:number] forKey:[NSNumber numberWithInt:number.intValue - 1]];
            }
        }
        self.loadedCells = newLoadedCells;
    }
}

-(void)diseaseTotalCellLocationDicStartIndex:(int)startIndex{
    
}
-(void)loadDataWithIndex:(int)index withColoumn:(int)column{
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:column];
    DRWaterFlowCell *cell = [self getCellAtIndex:index];
    DRImageData *cellData = [self getCellDataAtIndex:index];
    if (cell && cellData) {
        if (crit.bottomOffset.row > 0 && crit.bottomOffset.row < [[self.totalCellLocation objectAtIndex:column] count]) {
            FlowCellLocation *existLocation = [[self.totalCellLocation objectAtIndex:column] objectAtIndex:crit.bottomOffset.row];
            cell.frame = existLocation.imageRect;
        }else{
            cell.frame = CGRectMake([self getCellOriginXWithCloumnIndex:column],[self getCellOriginYWithCloumnIndex:column], [self getwidthOfOneColumn], [self getCellHeightWithImageData:cellData]);
        }
        cell.imageRowIndex = crit.bottomOffset.row <1 ?0:crit.bottomOffset.row;
        cell.imageColumnIndex = column;
        cell.imageID = index;
        cell.delegate = self;
        [cell downLoadImageWithURLStr:cellData.imageURLStr withPlaceHolderImage:self.placeHolderImage withSuccess:^(DRWaterFlowCell *cell) {
            
        } failure:^(NSError *error) {
            DRLOG(@"%@", @"DRGridViewCell download imaage error");
        }];
        [cell hiddenRemoveButton:!self.isAbleDelete];
        [self addSubview:cell];
        cell.testLabel.frame = CGRectMake(0, 1, cell.frame.size.width, 15);
        //store totalCellLocation arr
        if (index > self.loadedCellMaxIndex) {
            self.loadedCellMaxIndex = index;
            FlowCellLocation *cellLocation = [FlowCellLocation makeFlowCellLocationWithRow:cell.imageRowIndex withCol:cell.imageColumnIndex withID:cell.imageID withRect:cell.frame];
            [[self.totalCellLocation objectAtIndex:column] addObject:cellLocation];
        }
        
        //store loadedCells dic
        [self.loadedCells setObject:cell forKey:[NSNumber numberWithInt:cell.imageID]];
        [self modifyTotalColumnOffsetWithColumnIndex:column withFlowWaterCell:cell];
    }
    
}
-(void)unloadData{
    self.loadedCellMaxIndex = -1;
    [self.totalCellLocation removeAllObjects];
    [self.totalColumnOffset removeAllObjects];
    [self.cellPool removeAllObjects];
    self.currentPageIndex = -1;
    self.columnCount = 0;
    self.cellsCountForOnePage = 0;
    self.lastCacheOffset = (CGPoint){0,0};
    self.scrollViewDirection = SCROLL_DOWN;
    self.cacheContentLenghtRate = 0.0;
    self.isAbleDelete = NO;
    self.totalCellsCount = 0;
}

-(void)prepareLoadData{
    [self unloadData];
    self.currentPageIndex = 0;
    self.loadedCellMaxIndex = -1;
    self.cellsCountForOnePage = [self getCellsCountForOnePage];
    self.columnCount = [self getFlowViewColumnCount];
    self.cellSpace = [self getFlowViewCellSpace];
    self.cellWidth = [self getwidthOfOneColumn];
    [self defaultTotalCellLocation];
    [self defaultTotalColumnOffSet];
    self.lastCacheOffset = (CGPoint){0,0};
    self.scrollViewDirection = SCROLL_UP;
    self.isAbleDelete = NO;
    self.totalCellsCount = [self getCellTotalCount];
}

#pragma mark locate method

-(void)reSetCurrentPageIndex{
    if (self.totalCellsCount < [self getCellTotalCount]) {
        self.currentPageIndex++;
        self.totalCellsCount = [self getCellTotalCount];
    }
    if (self.currentPageIndex  > [self getFlowPagesCount]-1) {
        self.currentPageIndex--;
    }
}
-(void)modifyTotalColumnOffsetWithColumnIndex:(int)columnIndex withFlowWaterCell:(DRWaterFlowCell*)cell{
    //modify totalColumnOffset arr
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:columnIndex];
    FlowCritical newCrit;
    newCrit.offset = cell.frame.origin.y +self.cellSpace + cell.frame.size.height;
    newCrit.row = cell.imageRowIndex+1;
    crit.bottomOffset = newCrit;
}

- (void)addCellToReuseQueue: (DRWaterFlowCell *)cell {
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

// scrollView Delegate exece
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


//get cache content offset(top ,bottom)
-(DRFlowCacheOffset)getFlowCacheOffset{
    float scrollOffset = self.contentOffset.y;
    float selfHeight = self.frame.size.height;
    float rate = self.cacheContentLenghtRate < 0.0000001 ? CACHECONTENT_LENGHT_RATE:self.cacheContentLenghtRate;
    return (DRFlowCacheOffset){scrollOffset > selfHeight*(rate/2) ? (scrollOffset - selfHeight*(rate/2)):0.0,scrollOffset+selfHeight*(1+rate/2)};
}
-(void)setScrollViewContentSize{
    float maxOffset = [self getBottomMaxOffset];
    float scrollContentHeight = self.contentSize.height;
    if (maxOffset > scrollContentHeight) {
        self.contentSize = CGSizeMake(self.contentSize.width, maxOffset+ SCROLLVIEW_CONTENT_PER_HEIGHT);
    }
    if (self.contentSize.height < self.frame.size.height) {
        self.contentSize = CGSizeMake(self.frame.size.width, self.frame.size.height+1);
    }
    self.contentInset = UIEdgeInsetsZero;
    float footOriginY = self.contentSize.height > self.frame.size.height? self.contentSize.height:self.frame.size.height;
    //self.footFreshView.frame = CGRectMake(0,footOriginY, self.frame.size.width, 150);
}
//get bottom critical
-(float)getBottomMaxOffset{
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:[self getColumnIndexForBottomMaxOffset]];
    return crit.bottomOffset.offset;
}

//get top critacal
-(float)getTopMinOffset{
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:[self getColumnIndexForTopMinOffset]];
    return crit.bottomOffset.offset;
}
//get bottom max offset
-(int)getColumnIndexForBottomMaxOffset{
    int maxColoumnIndex = -1;
    float maxOffset = 0;
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        if (columnIndex == 0) {
            maxColoumnIndex = 0;
            maxOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] bottomOffset].offset;
        }else{
            float nextOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] bottomOffset].offset;
            if (nextOffset > maxOffset) {
                maxOffset = nextOffset;
                maxColoumnIndex = columnIndex;
            }
        }
    }
    return maxColoumnIndex;
}
//get top min offset
-(int)getColumnIndexForTopMinOffset{
    int minColoumnIndex = -1;
    float minOffset = 0;
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        if (columnIndex == 0) {
            minColoumnIndex = 0;
            minOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] topOffset].offset;
        }else{
            float nextOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] topOffset].offset;
            if (nextOffset < minOffset) {
                minOffset = nextOffset;
                minColoumnIndex = columnIndex;
            }
        }
    }
    return minColoumnIndex;
}


//get bottom min offset
-(int)getColumnIndexForBottomMinOffset{
    int minColoumnIndex = -1;
    float minOffset = 0;
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        if (columnIndex == 0) {
            minColoumnIndex = 0;
            minOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] bottomOffset].offset;
        }else{
            float nextOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] bottomOffset].offset;
            if (nextOffset < minOffset) {
                minOffset = nextOffset;
                minColoumnIndex = columnIndex;
            }
        }
    }
    return minColoumnIndex;
}
//get top max offset
-(int)getColumnIndexForTopMaxOffset{
    int maxColoumnIndex = -1;
    float maxOffset = 0;
    for (int columnIndex = 0; columnIndex < [self.totalColumnOffset count]; columnIndex++) {
        if (columnIndex == 0) {
            maxColoumnIndex = 0;
            maxOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] topOffset].offset;
        }else{
            float nextOffset = [(FlowViewCritical*)[self.totalColumnOffset objectAtIndex:columnIndex] topOffset].offset;
            if (nextOffset > maxOffset) {
                maxOffset = nextOffset;
                maxColoumnIndex = columnIndex;
            }
        }
    }
    return maxColoumnIndex;
}

-(DRImageData*)getCellDataAtIndex:(int)index{
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(flowView:dataForIndex:)]) {
        return [self.flowViewDelegate flowView:self dataForIndex:index];
    }
    return nil;
}


-(DRWaterFlowCell*)getCellAtIndex:(int)index{
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(flowView:cellForIndex:)]) {
        return [self.flowViewDelegate flowView:self cellForIndex:index];
    }
    return nil;
}

-(int)getCellCurrentLoadedmaxIndex{
    int maxCellIndex = 0;
    for (int columnIndex = 0; columnIndex < [self.totalCellLocation count]; columnIndex++) {
        FlowViewCritical *columnCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        NSArray *columnCellsArr = [self.totalCellLocation objectAtIndex:columnIndex];
        for (int rowIndex = 0; rowIndex < [columnCellsArr count]; rowIndex++) {
            FlowCellLocation *location = [columnCellsArr objectAtIndex:rowIndex];
            if (location.imageRowIndex < columnCrit.bottomOffset.row && location.imageID > maxCellIndex) {
                maxCellIndex = location.imageID;
            }
            if (location.imageRowIndex >= columnCrit.bottomOffset.row) {
                break;
            }
        }
    }
    return maxCellIndex;
}
-(int)getCellMaxIndexForBottomCritical{
    int maxCellIndex = 0;
    for (int columnIndex = 0;columnIndex < [self.totalColumnOffset count];columnIndex++) {
        FlowViewCritical *columnCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        if (columnCrit.bottomOffset.row < 1) {
            continue;
        }
        if ([[self.totalCellLocation objectAtIndex:columnIndex] count] < columnCrit.bottomOffset.row) {
            NSLog(@">>>>>>>>totalCelllocation error:totalCelllocation count smaller than bottomOffset.row");
            break;
        }
        FlowCellLocation *location = [[self.totalCellLocation objectAtIndex:columnIndex] objectAtIndex:columnCrit.bottomOffset.row-1];
        if (maxCellIndex < location.imageID) {
            maxCellIndex = location.imageID;
        }
    }
    return maxCellIndex;
}

-(int)getCellMinIndexForTopCritical{
    int minCellIndex = 0;
    for (int columnIndex = 0;columnIndex < [self.totalColumnOffset count];columnIndex++) {
        FlowViewCritical *columnCrit = [self.totalColumnOffset objectAtIndex:columnIndex];
        if (columnCrit.bottomOffset.row < 1) {
            continue;
        }
        if ([[self.totalCellLocation objectAtIndex:columnIndex] count] < columnCrit.bottomOffset.row) {
            NSLog(@">>>>>>>>totalCelllocation error:totalCelllocation count smaller than bottomOffset.row");
            break;
        }
        FlowCellLocation *location = [[self.totalCellLocation objectAtIndex:columnIndex] objectAtIndex:columnCrit.bottomOffset.row-1];
        if (minCellIndex > location.imageID) {
            minCellIndex = location.imageID;
        }
    }
    return minCellIndex;
}

//get current page cell count
-(int)getMaxCellIndexForPageIndex:(int)pageIndex{
    if (self.cellsCountForOnePage <= 0) {
        return -1;
    }
    int pageCount = [self getFlowPagesCount];
    
    if (pageIndex >= pageCount) {
        return -1;
    }
    if ([self getCellTotalCount] < self.cellsCountForOnePage) {
        return [self getCellTotalCount] - 1;
    }
    if (pageIndex < pageCount-1) {
        return (1+pageIndex)*self.cellsCountForOnePage - 1;
    }else{
        return [self getCellTotalCount] - 1;
    }
    
}

//get all page count
-(int)getFlowPagesCount{
    if (self.cellsCountForOnePage <= 0) {
        return -1;
    }
    int totalCellCount = [self getCellTotalCount];
    if (totalCellCount%self.cellsCountForOnePage != 0) {
        return totalCellCount/self.cellsCountForOnePage + 1;
    }
    return totalCellCount/self.cellsCountForOnePage;
}
//get all cell count from server
-(int)getCellTotalCount{
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(totalDataNumbers)]) {
        return [self.flowViewDelegate totalDataNumbers];
    }
    return 0;
}
//get cell count for one page
-(int)getCellsCountForOnePage{
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(numberOfFlowViewOnePage)]) {
        return [self.flowViewDelegate numberOfFlowViewOnePage];
    }
    return 0;
}

//get cell origin Y
-(float)getCellOriginXWithCloumnIndex:(int)column{
    return (column*2+1)*self.cellSpace + column*self.cellWidth;
}

// if:1.maxOffset is in obj,return true
//    2.maxoffset is on obj top, return false,
//    3.maxoffset is on obj bottom,return ture
-(FlowCellLocation*)getCellLocatitonForMaxOffset:(float)maxOffset withColumnIndex:(int)columnIndex withStartRowIndex:(int)startRowIndex withEndRowIndex:(int)endRowIndex{
    //
    if (columnIndex > [self.totalCellLocation count] || columnIndex == [self.totalCellLocation count]) {
        return nil;
    }
    //
    NSArray *rowsArr = [self.totalCellLocation objectAtIndex:columnIndex];
    if (endRowIndex > [rowsArr count] || endRowIndex == [rowsArr count]) {
        return nil;
    }
    
    FlowCellLocation *endLocation = [rowsArr objectAtIndex:endRowIndex];
    FlowCellLocation *startLocation = [rowsArr objectAtIndex:startRowIndex];
    
    //
    if (maxOffset >= endLocation.imageRect.origin.y + endLocation.imageRect.size.height) {
        return endLocation;
    }
    if (maxOffset <= startLocation.imageRect.origin.y) {
        return startLocation;
    }
    //
    if ([endLocation judgeFlowCellRectContainOffset:maxOffset]) {
        return endLocation;
    }else if([startLocation judgeFlowCellRectContainOffset:maxOffset]){
        return startLocation;
    }
    
    //
    if (endRowIndex - startRowIndex < 2) {
        return endLocation;
    }
    
    int middleIndex = (startRowIndex + endRowIndex)/2;
    FlowCellLocation *middleLocation = [rowsArr objectAtIndex:middleIndex];
    //
    float middleOffset = middleLocation.imageRect.origin.y;
    if ([middleLocation judgeFlowCellRectContainOffset:maxOffset]) {
        return middleLocation;
    }
    
    if (middleOffset > maxOffset) {
        return [self getCellLocatitonForMaxOffset:maxOffset withColumnIndex:columnIndex withStartRowIndex:startRowIndex+1 withEndRowIndex:middleIndex-1];
    }else{
        return [self getCellLocatitonForMaxOffset:maxOffset withColumnIndex:columnIndex withStartRowIndex:middleIndex+1 withEndRowIndex:endRowIndex-1];
    }
}
//get cell origin Y
-(float)getCellOriginYWithCloumnIndex:(int)column{
    FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:column];
    float cellY = crit.bottomOffset.offset;
    return cellY + self.cellSpace;
}

//get space for cell
-(int)getFlowViewCellSpace{
    if (_flowViewDelegate &&[_flowViewDelegate respondsToSelector:@selector(spaceOfFlowViewCells)]) {
        return [_flowViewDelegate spaceOfFlowViewCells];
    }
    return FLOWVIEWCELL_SPACE;
}

//get width for each column
-(float)getwidthOfOneColumn{
    return (self.frame.size.width - [self getFlowViewCellSpace]*self.columnCount*2)/self.columnCount;
}


-(int)getCellsCountFromTotalCellLocation{
    int count = 0;
    for (int columnIndex = 0; columnIndex < [self.totalCellLocation count]; columnIndex++) {
        count +=[[self.totalCellLocation objectAtIndex:columnIndex] count];
    }
    return count;
}


//scale image height by width
-(float)getCellHeightWithImageData:(DRImageData*)imageData{
    return imageData.imageHeight*([self getwidthOfOneColumn]/imageData.imageWidth);
}

//get number of columns
-(int)getFlowViewColumnCount{
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(numberOfFlowViewColumns)]) {
        return [self.flowViewDelegate numberOfFlowViewColumns];
    }
    return 0;
}


//init totalCellLocation (row,column)
-(void)defaultTotalCellLocation{
    for (int i = 0; i < self.columnCount; i++) {
        //store rows of each column
        [self.totalCellLocation addObject:[NSMutableArray arrayWithCapacity:0]];
    }
}


//init totalColumnOffset (FlowViewCritical)
-(void)defaultTotalColumnOffSet{
    for (int columnIndex = 0; columnIndex < self.columnCount; columnIndex++) {
        FlowCritical crit;
        crit.offset = 0.0;
        crit.row = -1;
        [self.totalColumnOffset addObject:[FlowViewCritical criticalWithColumnIndex:columnIndex withTop:crit withBottom:crit]];
    }
}

-(void)setFlowCellIsAbleDelete:(BOOL)isDelete{

    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[DRWaterFlowCell class]]) {
            [(DRWaterFlowCell*)subView hiddenRemoveButton:!isDelete];
        }
    }
}
#pragma mark -

#pragma mark porperty


-(EGORefreshTableHeaderView *)refreshView{
    if (!_refreshView) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -150, self.frame.size.width, 150)];
        _refreshView.backgroundColor = [UIColor redColor];
        _refreshView.delegate = self;
        [self addSubview:_refreshView];
    }
    return _refreshView;
}

-(NSMutableArray *)totalCellLocation{
    if (!_totalCellLocation) {
        _totalCellLocation = [NSMutableArray arrayWithCapacity:_columnCount];
    }
    return _totalCellLocation;
}

-(NSMutableArray *)totalColumnOffset{
    if (!_totalColumnOffset) {
        _totalColumnOffset = [NSMutableArray arrayWithCapacity:_columnCount];
    }
    return _totalColumnOffset;
}

-(NSMutableDictionary *)loadedCells{
    if (!_loadedCells) {
        _loadedCells = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _loadedCells;
}
#pragma mark -

#pragma mark DRWaterFlowCellDelegate
-(void)flowCell:(DRWaterFlowCell *)flowCell removeButtonClickWithCellIndex:(int)index{
    NSLog(@"remove index:%d",index);
    @synchronized(self){
    [self scrollViewRemoveSelectedCell:flowCell];
    }
    
    if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(flowView:didDeletedIndex:)]) {
        [self.flowViewDelegate flowView:self didDeletedIndex:index];
    }
}

-(void)flowCell:(DRWaterFlowCell *)flowCell selectedCellAtIndex:(int)index{
    NSLog(@"selectedCellAtIndex:%d,frame:%@",index,NSStringFromCGRect(flowCell.frame));
    if (_isAbleDelete) {
        _isAbleDelete = !_isAbleDelete;
        [self setFlowCellIsAbleDelete:_isAbleDelete];
    }else{
    //selected
        if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(flowView:didSelectedIndex:)]) {
            [self.flowViewDelegate flowView:self didSelectedIndex:index];
        }
    }
}

-(void)flowCell:(DRWaterFlowCell *)flowCell longPressCellAtIndex:(int)index{
    NSLog(@"longPressCellAtIndex:%d",index);
    if (!_isAbleDelete) {
        _isAbleDelete = !_isAbleDelete;
        [self setFlowCellIsAbleDelete:_isAbleDelete];
    }
}
#pragma mark --

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.isloadingData) {
        return;
    }
    [self scrollViewScrollEnd];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    [self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];
    if (self.isloadingData) {
        return;
    }
    if (decelerate) {
        DRFlowCacheOffset cacheOffset = [self getFlowCacheOffset];
        FlowViewCritical *crit = [self.totalColumnOffset objectAtIndex:[self getColumnIndexForBottomMinOffset]];
        if (crit.bottomOffset.offset < cacheOffset.bottomOffset) {
            [self scrollViewScrollEnd];
        }
    }else{
        [self scrollViewScrollEnd];
    }
   
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}
#pragma mark --

#pragma mark EGORefreshTableDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	self.isloadingData = YES;
    self.isAbleDelete = NO;
    [self setFlowCellIsAbleDelete:NO];
    if (true) {
        if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(flowView:prepareLoadNextPageDataFrom:to:)]) {
            [self.flowViewDelegate flowView:self prepareLoadNextPageDataFrom:[self getMaxCellIndexForPageIndex:self.currentPageIndex] +1 to:self.cellsCountForOnePage*(self.currentPageIndex+2) -1];
        }
    }else{
        if (self.flowViewDelegate && [self.flowViewDelegate respondsToSelector:@selector(prepareReloadData:)]) {
            [self.flowViewDelegate prepareReloadData:self];
        }
    }
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.isloadingData; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}
#pragma mark --

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.isDragging) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
//        NSLog(@"%@",NSStringFromCGPoint(point));
        FlowCellLocation *location = [self getCellLocatitonForMaxOffset:point.y withColumnIndex:1 withStartRowIndex:0 withEndRowIndex:[[self.totalCellLocation objectAtIndex:1] count] -1];
//        NSLog(@"selected location:index:%d,RECT:%@",location.imageID,NSStringFromCGRect(location.imageRect));
//        NSLog(@"max lodaded index:%d",[self getCellMaxIndexForBottomCritical]);
    }
    
}
@end
