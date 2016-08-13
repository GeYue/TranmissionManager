//
//  JobsTableCell.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/9.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "JobsTableCell.h"
#import "TorrentJobsViewController.h"
#import "MGSwipeTableCell/MGSwipeButton.h"
#import "TorrentDelegate.h"
#import "AppConfig.h"

@implementation JobsTableCell

- (instancetype) jobsTableViewCell:(UITableView *)tableView JobContentInfo:(NSDictionary *)jobInfo
{
    NSString *identifier = [NSString stringWithFormat:@"JobsCell%@", [AppConfig.getInstance getValueForKey:@"runningConfig"][@"cell"]];
    
    NSInteger index = 0;
    JobsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TorrentJobsViewController" owner:self options:nil] objectAtIndex:index];
    }
    
    MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor]
                                                  callback:^BOOL(MGSwipeTableCell *sender) {
                                                      NSLog(@"Table cell delete action called.");
                                                      return YES;
                                                  }];
    
    if ([jobInfo[@"status"] isEqualToString:@"Paused"]){
        cell.rightButtons = @[delete,
                              [MGSwipeButton buttonWithTitle:@"Resume" backgroundColor:[UIColor greenColor]
                                                    callback:^BOOL(MGSwipeTableCell *sender) {
                                                        NSLog(@"Table cell resume action called.");
                                                        [TorrentDelegate.sharedInstance.currentSelectedClient resumeTorrent:jobInfo[@"hash"]];
                                                        return YES; }]];
        
    } else {
        cell.rightButtons = @[delete,
                              [MGSwipeButton buttonWithTitle:@"Pause" backgroundColor:[UIColor lightGrayColor]
                                                    callback:^BOOL(MGSwipeTableCell *sender) {
                                                        NSLog(@"Table cell pause action called.");
                                                        [TorrentDelegate.sharedInstance.currentSelectedClient pauseTorrent:jobInfo[@"hash"]];
                                                        return YES; }]];
    }
    cell.torrentName.text = jobInfo[@"name"];
    cell.uploadSpeed.text = [NSString stringWithFormat:@"↑ %@", jobInfo[@"uploadSpeed"]];
    cell.downloadSpeed.text = [NSString stringWithFormat:@" ↓%@", jobInfo[@"downloadSpeed"]];
    cell.currentStatus.text = jobInfo[@"status"];
    
    if ([jobInfo[@"ETA"] length] && [jobInfo[@"progress"] doubleValue] != [[TorrentDelegate.sharedInstance.currentSelectedClient.class completeNumber] doubleValue])
    {
        cell.etaInfo.text = [NSString stringWithFormat:@"ETA: %@", jobInfo[@"ETA"]];
    }
    else if (jobInfo[@"ratio"])
    {
        cell.etaInfo.text = [NSString stringWithFormat:@"Ratio: %.3f", [jobInfo[@"ratio"] doubleValue]];
    }
    else
    {
        cell.etaInfo.text = @"";
    }
    
    double completeValue = [[TorrentDelegate.sharedInstance.currentSelectedClient.class completeNumber] doubleValue];
    cell.progressBar.progress = completeValue ? [jobInfo[@"progress"] doubleValue] / completeValue : 0;
    
    if ([jobInfo[@"status"] isEqualToString:@"Seeding"]) {
        cell.progressBar.progressTintColor = [UIColor colorWithRed:0 green:1 blue:.4 alpha:1];
    } else if ([jobInfo[@"status"] isEqualToString:@"Downloading"]) {
        cell.progressBar.progressTintColor = [UIColor colorWithRed:0 green:.478 blue:1 alpha:1];
    } else {
        cell.progressBar.progressTintColor = [UIColor darkGrayColor];
    }

    return cell;
}

- (void) setSwipeOffset:(CGFloat)swipeOffset {
    [super setSwipeOffset:swipeOffset];
    [self.table setShouldRefresh:swipeOffset == 0];
}

@end
