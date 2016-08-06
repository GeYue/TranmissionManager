//
//  AddClientViewController.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/13.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ADDCLIENTMODE) {
    ADDCLIENT_BY_INSERT,
    ADDCLIENT_BY_EDIT,
};

@interface AddClientViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIPickerView *ClientType;
@property (strong, nonatomic) IBOutlet UITextField *ClientName;
@property (strong, nonatomic) IBOutlet UITextField *ClientAddress;
@property (strong, nonatomic) IBOutlet UITextField *ClientPort;
@property (strong, nonatomic) IBOutlet UITextField *ClientUserName;
@property (strong, nonatomic) IBOutlet UITextField *ClientPasswd;
@property (strong, nonatomic) IBOutlet UISegmentedControl *useSSLSegmentCtrl;
@property (strong, nonatomic) IBOutlet UITextField *RelativePath;
@property (strong, nonatomic) IBOutlet UITextField *DirectoryPath;

@property (strong, nonatomic) IBOutlet UITableViewCell *RelativePathCell;


@property (nonatomic, assign) ADDCLIENTMODE nDispMode;
@property (nonatomic, strong) NSDictionary * clientDictionary;

@end
