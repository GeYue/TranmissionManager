//
//  UIInfoViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/8/14.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "UIInfoViewController.h"
#import "ExtSCGifImageView.h"

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

@interface UIInfoViewController () <MAMapViewDelegate>
{
    
    MAMapView * _mapView;
}
@end

@implementation UIInfoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"000.gif" ofType:nil];
    NSData * imageData = [NSData dataWithContentsOfFile:filePath];
    
    ExtSCGifImageView * gifImageView = [[ExtSCGifImageView alloc] initWithFrame:CGRectMake(30, 50, 256, 256)];
    [gifImageView setData:imageData];
    
    [AMapServices sharedServices].apiKey = @"951fc1b331728f94dbd8ac710091430c";
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(30, 300, CGRectGetWidth(self.view.bounds)-60, CGRectGetHeight(self.view.bounds)-100)];
    _mapView.delegate = self;
    
    [self.view addSubview:gifImageView];
    [self.view addSubview:_mapView];
}

@end
