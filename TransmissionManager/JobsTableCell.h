//
//  JobsTableCell.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/9.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

@class TorrentJobsViewController;

@interface JobsTableCell : MGSwipeTableCell
@property (strong, nonatomic) IBOutlet UILabel *torrentName;
@property (strong, nonatomic) IBOutlet UILabel *uploadSpeed;
@property (strong, nonatomic) IBOutlet UILabel *downloadSpeed;
@property (strong, nonatomic) IBOutlet UILabel *currentStatus;
@property (strong, nonatomic) IBOutlet UILabel *etaInfo;
@property (strong, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, weak) TorrentJobsViewController * table;

- (instancetype) jobsTableViewCell:(UITableView *)tableView JobContentInfo:(NSDictionary *)jobInfo;

- (void) setSwipeOffset:(CGFloat)swipeOffset;

@end
