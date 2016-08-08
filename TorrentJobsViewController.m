//
//  TorrentJobsViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/7.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentJobsViewController.h"
#import "TorrentJobsViewController+NavBar.h"
#import "TorrentDetailViewController.h"
#import "JobsTableCell.h"
#import "TorrentDelegate.h"

@interface TorrentJobsViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchControllerDelegate>

@end

@implementation TorrentJobsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialiseHeader];
    
    [self setupNavToolbarView];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    [self.searchController setSearchResultsUpdater:self];
    self.searchController.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.dimsBackgroundDuringPresentation = FALSE;
    self.searchController.definesPresentationContext = TRUE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUpdateJobsNotification)
                                                 name:@"update_torrent_jobs_table" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveUpdateHeaderNotification)
                                                 name:@"update_torrent_jobs_header" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.toolbar setHidden:NO];
    self.shouldRefresh = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initialiseHeader
{
    self.header = [UILabel.alloc initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    self.header.backgroundColor = [UIColor colorWithRed:0 green:0.9 blue:.2 alpha:.85];
    self.header.textColor = [UIColor whiteColor];
    self.header.text = @"Attempting Connection";
    self.header.font = [UIFont fontWithName:@"Arial" size:30 - 6];
    self.header.textAlignment = NSTextAlignmentCenter;
    self.header.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - IBAction functions
- (IBAction)OpenWebUI:(id)sender
{
    NSLog(@"NavigationItem.leftBarButtonItem clicked.");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSMutableArray * dictValues = [[TorrentDelegate.sharedInstance.currentSelectedClient.getJobsDict allValues] mutableCopy];
    [self sortArray:dictValues];
    self.sortedAllJobs = dictValues;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active && self.searchController.searchBar.text.length > 0) {
        return [self.filtedJobs count];
    }
    return [[TorrentDelegate.sharedInstance.currentSelectedClient getJobsDict] count];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * currentJob = [self getCurrentJobDict:indexPath.row];
    JobsTableCell *cell = [[JobsTableCell alloc] jobsTableViewCell:tableView JobContentInfo:currentJob];
    cell.table = self;
    
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.shouldRefresh ? self.header : nil;
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    TorrentDetailViewController * detailViewController = [storyBoard instantiateViewControllerWithIdentifier:@"TorrentDetailViewController"];
    detailViewController.jobDict = [self getCurrentJobDict:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];    
}

#pragma mark - UISearchResultsUpdating
- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterContentForSearchText:searchController.searchBar.text Scope:@"testScope"];
    [self.tableView reloadData];
}

- (void) willPresentSearchController:(UISearchController *)searchController {
    self.shouldRefresh = NO;
}

- (void) willDismissSearchController:(UISearchController *)searchController {
    self.shouldRefresh = YES;
}

#pragma mark - Notification Observer

- (void) receiveUpdateJobsNotification {
    if ( self.shouldRefresh && !self.tableView.isEditing
        && !self.tableView.isDragging && !self.tableView.isDecelerating ) {
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    [self refreshDownloadUploadTotals];
}

- (void) receiveUpdateHeaderNotification {
    if ([TorrentDelegate.sharedInstance.currentSelectedClient isHostOnline]) {
        self.header.text = @"Host Online";
        self.header.backgroundColor = [UIColor colorWithRed:.302 green:.584 blue:.772 alpha:.85];
    } else {
        self.header.text = @"Host Offline";
        self.header.backgroundColor = [UIColor colorWithRed:.98 green:.196 blue:.196 alpha:.85];
    }
}

#pragma mark - Others

- (void) refreshDownloadUploadTotals {
    NSUInteger uploadSpeed = 0, downloadSpeed = 0;
    for (NSDictionary * dict in TorrentDelegate.sharedInstance.currentSelectedClient.getJobsDict.allValues) {
        if (dict[@"rawUploadSpeed"] && dict[@"rawDownloadSpeed"]) {
            uploadSpeed += [dict[@"rawUploadSpeed"] integerValue];
            downloadSpeed += [dict[@"rawDownloadSpeed"] integerValue];
        }
    }
   // dispatch_async(dispatch_get_main_queue(), ^{
   //     self.uploadTotalLabel.text = [NSString stringWithFormat:@"↑ %@", @(uploadSpeed).transferRateString];
   //     self.downloadTotalLabel.text = [NSString stringWithFormat:@"↓ %@", @(downloadSpeed).transferRateString];
   // });
}

- (void) filterContentForSearchText:(NSString *)searchText Scope:(NSString *)scope {
    NSDictionary * jobs = [TorrentDelegate.sharedInstance.currentSelectedClient getJobsDict];
    self.filtedJobs = [[NSMutableArray alloc] init];
    for (NSDictionary * job in jobs.allValues) {
        if ([[job[@"name"] lowercaseString] containsString:[searchText lowercaseString]]) {
            [self.filtedJobs addObject:job];
        }
    }
    //[self sortArray:filtedJobs];
}

- (NSDictionary *) getCurrentJobDict:(NSInteger) index {
    NSDictionary * currentJob = nil;
    if (self.searchController.active && self.searchController.searchBar.text.length > 0) {
        currentJob = self.filtedJobs[index];
    } else {
        currentJob = self.sortedAllJobs[index];
    }
    return currentJob;
}

- (JobOrder) getJobStatusENUM:(NSString *) strStatus {
    if ([strStatus isEqualToString:@"Downloading"])
        return DOWNLOADING;
    else if ([strStatus isEqualToString:@"Seeding"])
        return SEEDING;
    else if ([strStatus isEqualToString:@"Paused"])
        return PAUSED;
    else
        return JOB_ORDER_END_MARK;
}

- (NSComparisonResult)orderBy:(NSComparisonResult)orderBy comparing:(NSDictionary *)a with:(NSDictionary *)b usingKey:(NSString *)key
{
    if (a[key] && b[key])
    {
        NSComparisonResult res = orderBy != NSOrderedAscending ? [a[key] compare:b[key]] : [b[key] compare:a[key]];
        return res != NSOrderedSame ? res : [a[@"name"] compare:b[@"name"]];
    }
    return [a[@"name"] compare:b[@"name"]];
}

- (void)sortArray:(NSMutableArray *)array
{
    NSInteger orderBy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"runningConfig"][@"order_by"] integerValue];
    NSInteger sortBy = [[[NSUserDefaults standardUserDefaults] objectForKey:@"runningConfig"][@"sort_by"] integerValue];
    switch (sortBy)
    {
        case COMPLETED:
        case INCOMPLETE:
        {
            [array sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"progress"];
            }];
            break;
        }
        case DOWNLOAD_SPEED:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"rawDownloadSpeed"];
            }];
            break;
        }
        case UPLOAD_SPEED:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"rawUploadSpeed"];
            }];
            break;
        }
        case ACTIVE:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                if ([a[@"rawUploadSpeed"] integerValue] | [a[@"rawDownloadSpeed"] integerValue])
                {
                    if (!([b[@"rawUploadSpeed"] integerValue] | [b[@"rawDownloadSpeed"] integerValue]))
                    {
                        return orderBy != NSOrderedAscending ? NSOrderedAscending : NSOrderedDescending;
                    }
                }
                else if ([b[@"rawUploadSpeed"] integerValue] | [b[@"rawDownloadSpeed"] integerValue])
                {
                    return orderBy != NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending;
                }
                return [a[@"name"] compare:b[@"name"]];
            }];
            break;
        }
        case DOWNLOADING:
        case SEEDING:
        case PAUSED:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                NSInteger firstJobStatus = [self getJobStatusENUM:a[@"status"]];
                NSInteger secondJobStatus = [self getJobStatusENUM:b[@"status"]];
                if (firstJobStatus == sortBy)
                {
                    if (!(secondJobStatus == sortBy))
                    {
                        return orderBy != NSOrderedAscending ? NSOrderedAscending : NSOrderedDescending;
                    }
                }
                else if (secondJobStatus == sortBy)
                {
                    return orderBy != NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending;
                }
                return [a[@"name"] compare:b[@"name"]];
            }];
            break;
        }
        case SIZE:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"size"];
            }];
            break;
        }
        case RATIO:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"ratio"];
            }];
            break;
        }
        case DATE_ADDED:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"dateAdded"];
            }];
            break;
        }
        case DATE_FINISHED:
        {
            [array sortUsingComparator:(NSComparator)^(NSDictionary *a, NSDictionary *b){
                return [self orderBy:orderBy comparing:b with:a usingKey:@"dateDone"];
            }];
            break;
        }
        default:
        case NAME:
        {
            [array sortUsingComparator: (NSComparator)^(NSDictionary *a, NSDictionary *b){
                return orderBy != NSOrderedAscending ? [b[@"name"] compare:a[@"name"]] : [a[@"name"] compare:b[@"name"]];
            }];
            break;
        }
    }
}

@end


