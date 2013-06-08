//
//  NotificationController.m
//  PhotoUploadTool
//
//  Created by david on 13-5-24.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import "NotificationController.h"
#import "NotificationCell.h"
#define NOTIFICATION_FONT_SIZE  15
@interface NotificationController ()
@property(nonatomic,strong) EGORefreshTableHeaderView *refreshView;
@property(nonatomic,strong)NSMutableArray *notificationArr;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign) BOOL isloadingData;
@property(nonatomic,assign) NSIndexPath *selectedPath;
@end

@implementation NotificationController

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
    [self.tabbarRightBt setTitle:@"编辑" forState:UIControlStateNormal];
    [self.tabbarRightBt setBackgroundColor:[UIColor blueColor]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"privatePwd_bg.png"]];
	// Do any additional setup after loading the view.
    for (int i = 0; i < 20; i++) {
        [self.notificationArr addObject:[NotificationObject initNotificationWithDateStr:@"2012/01/01" withDetailStr:@"umhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9oniumhoiumh9s9s8g9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s9msoiihsoshoniumhoiumh9s9s8g9msoiihsoshoniumhoiumh9s98g9msoiihsoshhis vnyguiwh m0ws9ui ,s9u"]];
    }
    [self.contentView addSubview:self.tableView];
}

-(void)loadedData{
    self.isloadingData = NO;
    self.selectedPath = nil;
    [self.tableView reloadData];
    [self.refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

//继承该方法时,左右滑动会出现删除按钮(自定义按钮),点击按钮时的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.notificationArr removeObjectAtIndex:indexPath.row];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    if (indexPath) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    }

    
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}


//当 tableview 为 editing 时,左侧按钮的 style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    cell.dateLabel.text = obj.date;
    cell.summaryLabel.text = obj.deail;
    cell.backImageView.image = [[UIImage imageNamed:@"input_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
    cell.detalLabel.text = obj.deail;
    if ([obj.isExpand boolValue]) {
        [cell.summaryLabel setHidden:YES];
        [cell.detalLabel setHidden:NO];
        cell.detalLabel.numberOfLines = 0;
        [cell.detalLabel sizeToFit];
    }else{
        [cell.summaryLabel setHidden:NO];
        [cell.detalLabel setHidden:YES];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    if ([obj.isExpand boolValue]) {
        CGSize detailSize = [obj.deail sizeWithFont:[UIFont systemFontOfSize:NOTIFICATION_FONT_SIZE] constrainedToSize:CGSizeMake(279, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
        return detailSize.height +41;
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationObject *obj = [self.notificationArr objectAtIndex:indexPath.row];
    obj.isExpand = [NSNumber numberWithBool:![obj.isExpand boolValue]];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.notificationArr count];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)notificationArr{
    if (!_notificationArr) {
        _notificationArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _notificationArr;
}

#pragma mark property

-(EGORefreshTableHeaderView *)refreshView{
    if (!_refreshView) {
        _refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -150, self.view.frame.size.width, 150)];
        _refreshView.backgroundColor = [UIColor clearColor];
        _refreshView.delegate = self;
        [self.tableView addSubview:_refreshView];
    }
    return _refreshView;
}

-(UITableView *)tableView{
    if (!_tableView) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Storyboard_iphone" bundle:nil];
        _tableView = (UITableView*)[[story instantiateViewControllerWithIdentifier:@"NotificationTableViewController"] view];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
#pragma mark --

#pragma mark EGORefreshTableDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	self.isloadingData = YES;
    [self performSelector:@selector(loadedData) withObject:nil afterDelay:3.0];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return self.isloadingData; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark ScrollViewDelegate
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.tableView.editing) {
        return;
    }
    [self.refreshView egoRefreshScrollViewDidEndDragging:scrollView];    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.editing) {
        return;
    }
    [self.refreshView egoRefreshScrollViewDidScroll:scrollView];
    
}
#pragma mark --
- (IBAction)backBtClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidUnload {
    [self setTabbarTitleLabel:nil];
    [self setContentView:nil];
    [self setTabbarRightBt:nil];
    [super viewDidUnload];
}
- (IBAction)tabbarEditBtClicked:(UIButton *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    self.selectedPath = nil;
    //    [self.tableView reloadData];
    if (self.tableView.editing) {
        [self.tabbarRightBt setTitle:@"取消" forState:UIControlStateNormal];
        [self.tabbarRightBt setBackgroundColor:[UIColor redColor]];
    }else{
        [self.tabbarRightBt setTitle:@"编辑" forState:UIControlStateNormal];
        [self.tabbarRightBt setBackgroundColor:[UIColor blueColor]];
    }
}
@end
