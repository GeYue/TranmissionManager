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
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

@interface UIInfoViewController () <MAMapViewDelegate>
{
    
    MAMapView * _mapView;
}
@property (strong, nonatomic) IBOutlet UIButton *LocationButton;
@property (nonatomic, strong) AMapLocationManager * locationManager;
@end

@implementation UIInfoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"000.gif" ofType:nil];
    NSData * imageData = [NSData dataWithContentsOfFile:filePath];
    
    ExtSCGifImageView * gifImageView = [[ExtSCGifImageView alloc] initWithFrame:CGRectMake(30, 50, 256, 256)];
    [gifImageView setData:imageData];
    
    [AMapServices sharedServices].apiKey = @"951fc1b331728f94dbd8ac710091430c";
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(30, 300, CGRectGetWidth(self.view.bounds)-60, CGRectGetHeight(self.view.bounds)-350)];
    _mapView.delegate = self;
    
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    [self.view addSubview:gifImageView];
    [self.view addSubview:_mapView];
}

- (void) startSerialLocation {
    [self.locationManager startUpdatingLocation];
}

- (void) stopSerialLocation {
    [self.locationManager stopUpdatingLocation];
}

- (IBAction)ClickedLocation:(id)sender {
    [self startSerialLocation];
}

#pragma mark - AMapLocationManagerDelegate

- (void) amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void) amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    NSLog(@"location:{lat:%f, lon:%f, accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
}

@end
