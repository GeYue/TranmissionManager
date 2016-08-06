//
//  AddClientViewController.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/13.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "AddClientViewController.h"
#import "TorrentDelegate.h"
#import "AppConfig.h"

@interface AddClientViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) NSString * selectedClientName;
@property (nonatomic, strong) NSArray * sortedNameArray;

@end

@implementation AddClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.toolbar setHidden:NO];
    if (ADDCLIENT_BY_INSERT == _nDispMode) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(viewDismiss)];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveConfig)];
    self.sortedNameArray = [[TorrentDelegate.sharedInstance.torrentDelegates allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.selectedClientName = @"Transmission";
    
    if (ADDCLIENT_BY_EDIT == self.nDispMode && self.clientDictionary) {
        self.ClientName.text        = self.clientDictionary[@"name"];
        self.ClientAddress.text     = self.clientDictionary[@"url"];
        self.ClientPort.text        = self.clientDictionary[@"port"];
        self.ClientUserName.text    = self.clientDictionary[@"username"];
        self.ClientPasswd.text      = self.clientDictionary[@"password"];
        self.RelativePath.text      = self.clientDictionary[@"relative_path"];
        self.DirectoryPath.text     = self.clientDictionary[@"directory"];
        self.useSSLSegmentCtrl.selectedSegmentIndex = [self.clientDictionary[@"use_ssl"] boolValue];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - member functions

- (void) viewDismiss {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveConfig {
    if (self.ClientName.text.length && self.ClientAddress.text.length) {
        NSMutableArray * array = [[AppConfig.getInstance getValueForKey:@"clients"] mutableCopy];
        if (!array) {
            array = [[NSMutableArray alloc] init];
        }
        
        NSDictionary * object = @{@"name":self.ClientName.text,
                                @"type":self.selectedClientName,
                                @"url":self.ClientAddress.text,
                                @"port":self.ClientPort.text,
                                @"username":self.ClientUserName.text,
                                @"password":self.ClientPasswd.text,
                                @"use_ssl":@(self.useSSLSegmentCtrl.selectedSegmentIndex),
                                @"relative_path":self.RelativePath.text,
                                @"directory":self.DirectoryPath.text};
        
        BOOL bObjInArray = NO;
        NSDictionary * dict = nil;
        for (dict in array) {
            if ([dict[@"name"] isEqualToString:object[@"name"]] && (ADDCLIENT_BY_INSERT != self.nDispMode)) {
                bObjInArray = YES;
                break;
            }
        }
        
        if (!bObjInArray) {
            [array addObject:object];
            [AppConfig.getInstance settingValuesByObject:array forKey:@"clients"];
        }
        else {
            UIAlertController * alertCtler = [UIAlertController alertControllerWithTitle:@"Client name exist"
                                                                                 message:[NSString stringWithFormat:@"You already have a client named: %@", self.ClientName.text]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Overwrite" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [array replaceObjectAtIndex:[array indexOfObject:dict] withObject:object];
                                                                  [AppConfig.getInstance settingValuesByObject:array forKey:@"clients"];
          }];
            
            [alertCtler addAction:cancelAction];
            [alertCtler addAction:okAction];
            [self presentViewController:alertCtler animated:YES completion:nil];
        }
       
        [AppConfig.getInstance settingVauesByDictionary:@{@"clientname":object[@"name"], @"server_type":object[@"type"]} forKey:@"runningConfig"];
        [self viewDismiss];
    }
}

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

#pragma mark - UIPickerView Datasource & Delegate

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.sortedNameArray count];
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.sortedNameArray[row];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedClientName = self.sortedNameArray[row];
}

@end
