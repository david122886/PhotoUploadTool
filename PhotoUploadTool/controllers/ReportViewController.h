//
//  ReportViewController.h
//  PhotoUploadTool
//
//  Created by david on 13-8-28.
//  Copyright (c) 2013年 Comdosoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController
- (IBAction)agreeReport:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)backBtClicked:(id)sender;

@end
