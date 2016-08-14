//
//  UIInfoViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/8/14.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "UIInfoViewController.h"
#import "ExtSCGifImageView.h"

@implementation UIInfoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"000.gif" ofType:nil];
    NSData * imageData = [NSData dataWithContentsOfFile:filePath];
    
    ExtSCGifImageView * gifImageView = [[ExtSCGifImageView alloc] initWithFrame:CGRectMake(30, 50, 256, 256)];
    [gifImageView setData:imageData];
    
    [self.view addSubview:gifImageView];    
}

@end
