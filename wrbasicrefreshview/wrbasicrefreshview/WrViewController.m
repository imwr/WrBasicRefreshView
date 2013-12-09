//
//  WrViewController.m
//  wrbasicrefreshview
//
//  Created by cdwangrui on 13-12-9.
//  Copyright (c) 2013年 王锐. All rights reserved.
//

#import "WrViewController.h"
#import "WrBasicRefreshView.h"

@interface WrViewController ()
{
    UILabel *testLabel;
}

@end

@implementation WrViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
    self.view.backgroundColor=[UIColor whiteColor];
    testLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.view.frame.size.width, 100)];
    testLabel.textAlignment = NSTextAlignmentCenter;
    testLabel.text = @"WrBasicRefreshView Test\n";
    [self.view addSubview:testLabel];
    
    //add WrBasicRefreshView
    WrBasicRefreshView *wrView = [[WrBasicRefreshView alloc] initRefresh:self.view timeout:0];
    wrView.delegate = self;
    [self.view addSubview:wrView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)wrBasicRefreshUpdatingData:(WrBasicRefreshView*)wrView {
    testLabel.text = @"updating data...";
    [self performSelector:@selector(dataLoaded:) withObject:wrView afterDelay:3.0f];
}

- (void) dataLoaded :(WrBasicRefreshView*)wrView{
    testLabel.text = @"data was loaded...";
    [wrView wrBasicRefreshLoadedData];
}

@end
