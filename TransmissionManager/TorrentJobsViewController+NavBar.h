//
//  TorrentJobsViewController+NavBar.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/8.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#ifndef TorrentJobsViewController_NavBar_h
#define TorrentJobsViewController_NavBar_h

#import <UIKit/UIKit.h>
#import "TorrentJobsViewController.h"

@interface TorrentJobsViewController (NavBar) <UIPickerViewDelegate, UIPickerViewDataSource>


- (void) setupNavToolbarView;

@end


#endif /* TorrentJobsViewController_NavBar_h */
