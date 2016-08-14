//
//  TorrentClientsTabViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/9.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentClientsTabViewController.h"
#import "AddClientViewController.h"
#import "AppConfig.h"
#import "TorrentDelegate.h"

@interface TorrentClientsTabViewController ()

- (IBAction)SegCtrlValueChanged:(UISegmentedControl *)sender;

@property (nonatomic, strong) NSArray *dispModeArray;
@property (nonatomic, strong) UISegmentedControl *clientDispModeSegmentedCtrl;
@property (nonatomic, assign) NSInteger selectedClientIndex;

@end

@implementation TorrentClientsTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = @"Torrent Clients";
    [self.navigationController.toolbar setHidden:YES];
    
    self.dispModeArray = @[@"Pretty", @"Compact", @"Fast"];
    self.clientDispModeSegmentedCtrl = [[UISegmentedControl alloc] initWithItems:self.dispModeArray];
    self.selectedClientIndex = 0;
    
    //[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"styleCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    self.editing = NO;
    for (NSDictionary * dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"clients"]) {
        NSString * strClientName = [AppConfig.getInstance getValueForKey:@"runningConfig"][@"clientname"];
        if ([dict[@"name"] isEqualToString:strClientName])
        {
            self.selectedClientIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"clients"] indexOfObject:dict];
            break;
        }
    }
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [TorrentDelegate.sharedInstance performSelectorInBackground:@selector(credentialsCheckInvocation)
                                                     withObject:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ( 1 == section)
    {
        return [[AppConfig.getInstance getValueForKey:@"clients"] count];
    }
    return 1;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (1 == section){
        return @"Managed Clients:";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section)
    {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:@"styleCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        case 1:
            cell = [tableView dequeueReusableCellWithIdentifier:@"clientCell"];
            cell.textLabel.text = [AppConfig.getInstance getValueForKey:@"clients"][indexPath.row][@"name"];
            if (indexPath.row == self.selectedClientIndex) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 2:
            cell = [tableView dequeueReusableCellWithIdentifier:@"newClientCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        default:
            break;
    }
    return cell;
}

# pragma mark - table view delegates

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (1 == indexPath.section) {
        NSUInteger previousSelectClientIndex = self.selectedClientIndex;
        self.selectedClientIndex = indexPath.row;
        if (previousSelectClientIndex != self.selectedClientIndex) {
            [tableView reloadRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:previousSelectClientIndex inSection:indexPath.section]]
                             withRowAnimation:UITableViewRowAnimationNone];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSMutableArray * array = [[AppConfig.getInstance getValueForKey:@"clients"] mutableCopy];
            [AppConfig.getInstance settingVauesByDictionary:@{@"clientname":[array objectAtIndex:indexPath.row][@"name"], @"server_type":[array objectAtIndex:indexPath.row][@"type"]} forKey:@"runningConfig"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangedClient" object:nil];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (1 == indexPath.section) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        AddClientViewController *addClientViewCtrler = [storyboard instantiateViewControllerWithIdentifier:@"AddClientViewController"];
        addClientViewCtrler.nDispMode = ADDCLIENT_BY_EDIT;
        addClientViewCtrler.clientDictionary = [AppConfig.getInstance getValueForKey:@"clients"][indexPath.row];
        [self.navigationController pushViewController:addClientViewCtrler animated:YES];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (0 == indexPath.section){
        return UITableViewCellEditingStyleNone;
    }
    else if (1 == indexPath.section){
        return UITableViewCellEditingStyleDelete;
    }
    else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (UITableViewCellEditingStyleDelete == editingStyle){
        NSLog(@"selected editing style DELETE.");
        NSMutableArray * array = [[AppConfig.getInstance getValueForKey:@"clients"] mutableCopy];
        [array removeObjectAtIndex:indexPath.row];
        [AppConfig.getInstance settingValuesByObject:array forKey:@"clients"];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    if (UITableViewCellEditingStyleInsert == editingStyle){
        NSLog(@"selected editing style INSERT.");

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        AddClientViewController *addClientViewCtrler = [storyboard instantiateViewControllerWithIdentifier:@"AddClientViewController"];
        addClientViewCtrler.nDispMode = ADDCLIENT_BY_INSERT;
        [self.navigationController pushViewController:addClientViewCtrler animated:YES];
        
        //UINavigationController *navigatorController = [[UINavigationController alloc] initWithRootViewController:addClientViewCtrler];
        //navigatorController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:navigatorController action:@selector(viewDismiss)];
        //[self presentViewController:navigatorController animated:YES completion:nil];
    }
}

#pragma mark - IBAction
- (IBAction)SegCtrlValueChanged:(UISegmentedControl *)sender {
    NSInteger segSelectIndex = sender.selectedSegmentIndex;
    [AppConfig.getInstance settingVauesByDictionary:@{@"cell":self.dispModeArray[segSelectIndex]} forKey:@"runningConfig"];
}
@end
