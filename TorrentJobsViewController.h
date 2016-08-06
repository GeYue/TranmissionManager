//
//  TorrentJobsViewController.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/7.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, JobOrder) {
    COMPLETED = 0,
    INCOMPLETE,
    DOWNLOAD_SPEED,
    UPLOAD_SPEED,
    ACTIVE,
    DOWNLOADING,
    SEEDING,
    PAUSED,
    NAME,
    SIZE,
    RATIO,
    DATE_ADDED,
    DATE_FINISHED,
    JOB_ORDER_END_MARK
};

@interface TorrentJobsViewController : UITableViewController

@property (nonatomic, strong) UIBarButtonItem *addTorrentBtn;
@property (nonatomic, strong) UIBarButtonItem *infoAboutBtn;
@property (nonatomic, strong) UIBarButtonItem *sortTorrentBtn;
@property (nonatomic, strong) UIBarButtonItem *ctrlTorrentBtn;
@property (nonatomic, strong) UIBarButtonItem *cfgClientBtn;

@property (nonatomic, assign) BOOL shouldRefresh;
@property (nonatomic, strong) NSArray * sortedAllJobs;
@property (nonatomic, strong) NSMutableArray * filtedJobs;

@property (nonatomic, strong) UILabel * header;

@property (nonatomic, strong) UISearchController * searchController;
- (IBAction)OpenWebUI:(id)sender;

- (void)sortArray:(NSMutableArray *)array;

@end
