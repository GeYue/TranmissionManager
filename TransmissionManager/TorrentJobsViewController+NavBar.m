//
//  TorrentJobsViewController+NavBar.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/8.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentJobsViewController+NavBar.h"
#import "TorrentClientsTabViewController.h"
#import "UIInfoViewController.h"


@implementation TorrentJobsViewController (NavBar) 
- (void) setupNavToolbarView
{

    self.addTorrentBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                    action:@selector(ClickedBottomButton:)];
    [self.addTorrentBtn setTag:1];
    
    self.infoAboutBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(ClickedBottomButton:)];
    [self.infoAboutBtn setTag:2];
    
    self.sortTorrentBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Gripper"] style:UIBarButtonItemStylePlain
                                                          target:self action:@selector(SortAndOrder:)];
    [self.sortTorrentBtn setTag:3];
    
    self.ctrlTorrentBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"PlayPause"] style:UIBarButtonItemStylePlain
                                                          target:self action:@selector(ClickedBottomButton:)];
    [self.ctrlTorrentBtn setTag:4];
    
    self.cfgClientBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear"] style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(ClickedBottomButton:)];
    [self.cfgClientBtn setTag:5];
    
    UIBarButtonItem *splitSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil action:nil];
    
    [self setToolbarItems:[NSArray arrayWithObjects:self.addTorrentBtn, splitSpace,
                           self.infoAboutBtn, splitSpace, self.sortTorrentBtn, splitSpace,
                           self.ctrlTorrentBtn, splitSpace, self.cfgClientBtn, nil]];

}

- (void) SortAndOrder:(id) sender {
    UIAlertController * alertCtrler = [UIAlertController alertControllerWithTitle:@"Sort And Order" message:@"\n\n\n\n\n\n\n"
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    UIPickerView * sortOrderPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(30, 10, 280, 200)];
    NSString * strOrderBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"runningConfig"][@"order_by"];
    NSString * strSortBy = [[NSUserDefaults standardUserDefaults] objectForKey:@"runningConfig"][@"sort_by"];
    JobOrder enumOrderBy = [strSortBy integerValue];
    
    sortOrderPicker.delegate = self;
    sortOrderPicker.dataSource = self;
    [sortOrderPicker selectRow:([strOrderBy integerValue] == NSOrderedAscending ? 0 : 1) inComponent:0 animated:YES];
    [sortOrderPicker selectRow:enumOrderBy inComponent:1 animated:YES];
    [alertCtrler.view addSubview:sortOrderPicker];
    
    UIAlertAction * confirmAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.searchController.active) {
            [self sortArray:self.filtedJobs];
        } else {
            NSMutableArray *dictValues = [self.sortedAllJobs mutableCopy];
            [self sortArray:dictValues];
            self.sortedAllJobs = dictValues;
        }
        [self.tableView performSelector:@selector(reloadData)];
    }];
    
    [alertCtrler addAction:confirmAction];
    UIPopoverPresentationController * popoverController = [alertCtrler popoverPresentationController];
    popoverController.sourceView = self.navigationController.toolbar;
    popoverController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    UIView * targetView = [sender performSelector:@selector(view)];
    popoverController.sourceRect = targetView.frame;
    
    [self presentViewController:alertCtrler animated:YES completion:nil];
}

- (void) ClickedBottomButton:(id) sender
{
    NSLog(@"bottom button clicked.");
    UIBarButtonItem *buttonItem = (UIBarButtonItem *) sender;
    switch (buttonItem.tag) {
        case 1:
        {
            NSLog(@"This is button add.");
        }
            break;
        case 2:
        {
            NSLog(@"This is button info.");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            UIInfoViewController * infoViewController = [storyboard instantiateViewControllerWithIdentifier:@"UIInfoViewController"];
            [self.navigationController pushViewController:infoViewController animated:YES];
        }
            break;
        case 3:
        {
            NSLog(@"This is button sort.");
        }
            break;
        case 4:
        {
            NSLog(@"This is button play&pause.");
        }
            break;
        case 5:
        {
            //
            //TorrentClientsTabViewController *clientTabViewController = [[TorrentClientsTabViewController alloc] init];
            //[self.navigationController pushViewController:clientTabViewController animated:YES];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            TorrentClientsTabViewController *clientTabViewController = [storyboard instantiateViewControllerWithIdentifier:@"TorrentClientsTabViewController"];
            [self.navigationController pushViewController:clientTabViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIPickerView Delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (0 == component) {
        return 2;
    } else {
        return JOB_ORDER_END_MARK;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (0 == component)
        return 40;
    else
        return 160;
}

- (UIView *) pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel * dispLabel = [[UILabel alloc] init];
    if (0 == component) {
        switch (row) {
            case 0:
                dispLabel.text = @"Asc";
                break;
            case 1:
                dispLabel.text = @"Des";
                break;
            default:
                break;
        }
        dispLabel.font = [UIFont systemFontOfSize:22];
        dispLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        NSArray * dispArray = [NSArray arrayWithObjects:@"COMPLETED", @"INCOMPLETE", @"DOWNLOAD_SPEED", @"UPLOAD_SPEED", @"ACTIVE",
                               @"DOWNLOADING", @"SEEDING", @"PAUSED", @"SIZE", @"RATIO",
                               @"DATE_ADDED", @"DATE_FINISHED", @"NAME", nil];
        dispLabel.text = dispArray[row];
        dispLabel.font = [UIFont systemFontOfSize:15];
        dispLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return dispLabel;
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSMutableDictionary * mutableDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"runningConfig"] mutableCopy];
    if (0 == component) {
        mutableDict[@"order_by"] = [NSString stringWithFormat:@"%ld", (0 == row) ? NSOrderedAscending : NSOrderedDescending ];
    } else {
        mutableDict[@"sort_by"] = [NSString stringWithFormat:@"%ld", row];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableDict forKey:@"runningConfig"];
}


@end
