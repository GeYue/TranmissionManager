//
//  TorrentDetailViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/8/8.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentDetailViewController.h"
#import "TorrentDelegate.h"
#import "TorrentClient.h"

#import "NSNumber+StringCategory.h"

@interface TorrentDetailViewController ()

@property (nonatomic, weak) TorrentClient * client;
@property (nonatomic, strong) NSDateFormatter * formatter;
@property (nonatomic, assign) BOOL shouleRefresh;
@property (nonatomic, strong) NSArray * identifierArray;
@end

@implementation TorrentDetailViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.client = [[TorrentDelegate sharedInstance] currentSelectedClient];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateStyle:NSDateFormatterShortStyle];
    [self.formatter setTimeStyle:NSDateFormatterMediumStyle];
    self.identifierArray = @[@[@"", @"Size", @"Downloaded", @"Uploaded", @"Completed", @"Date Added", @"Date Finished"], @[@"Download", @"Upload", @"Seeds Connected", @"Peers Connected", @"Ratio", @"ETA"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUpdateTableNotification)
                                                 name:@"update_torrent_jobs_table" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.shouleRefresh = YES;
    [self setTitle:self.jobDict[@"name"]];
    [self receiveUpdateTableNotification];
}

- (void) viewWillDisappear:(BOOL)animated {
    self.shouleRefresh = NO;
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.jobDict) {
        [[self navigationController] popToRootViewControllerAnimated:NO];
        return 0;
    }
    [self setTitle:self.jobDict[@"name"]];
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (0 == section) {
        //return [self.identifierArray[section] count] - 2 + self.client.supportsAddedDate + (self.client.supportsCompletedDate && [hashDict[@"progress"] doubleValue] == [self.client.class completeNumber].doubleValue);
    //}
    return [self.identifierArray[section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"TorrentDetailCell"];
    
    cell.textLabel.text = [[self.identifierArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    switch (indexPath.section)
    {
        case 0:
            switch (indexPath.row)
        {
            case 0:
                cell.textLabel.text = self.jobDict[@"status"];
                break;
            case 1:
                cell.detailTextLabel.text = [self.jobDict[@"size"] sizeString];
                break;
            case 2:
                cell.detailTextLabel.text = self.jobDict[@"downloaded"];
                break;
            case 3:
                cell.detailTextLabel.text = self.jobDict[@"uploaded"];
                break;
            case 4:
            {
                double completeValue = [self.client.class completeNumber].doubleValue;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%%", completeValue ? [self.jobDict[@"progress"] doubleValue] / completeValue * 100 : [self.jobDict[@"progress"] doubleValue] / [self.jobDict[@"size"] doubleValue]];
                break;
            }
            case 5:
                cell.detailTextLabel.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.jobDict[@"dateAdded"] integerValue]]];
                break;
            case 6:
                cell.detailTextLabel.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.jobDict[@"dateDone"] integerValue]]];
                break;
        }
            break;
        case 1:
            switch (indexPath.row)
        {
            case 0:
                cell.detailTextLabel.text = [self.jobDict[@"downloadSpeed"] description];
                break;
            case 1:
                cell.detailTextLabel.text = [self.jobDict[@"uploadSpeed"] description];
                break;
            case 2:
                cell.detailTextLabel.text = [self.jobDict[@"seedsConnected"] description];
                break;
            case 3:
                cell.detailTextLabel.text = [self.jobDict[@"peersConnected"] description];
                break;
            case 4:
                cell.detailTextLabel.text = [self.jobDict[@"ratio"] description];
                break;
            case 5:
                cell.detailTextLabel.text = [self.jobDict[@"ETA"] description];
                break;
        }
            break;
    }
    return cell;
}

#pragma mark - NSNotification Observer
- (void) receiveUpdateTableNotification {
    if (self.shouleRefresh) {
        NSString * strHashString = self.jobDict[@"hash"];
        self.jobDict = [self.client getJobsDict][strHashString];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.playPauseButton.image = [UIImage imageNamed:[NSString stringWithFormat:@"UIButtonBar%@", [self.jobDict[@"status"] isEqualToString:@"Paused"] ? @"Play" : @"Pause"]];
        });
    }
}

#pragma mark - IBActions
- (IBAction)playPauseTorrentJob:(id)sender {
}

- (IBAction)removeTorrentJob:(id)sender {
}
@end
