//
//  TorrentDelegate.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/19.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentClient.h"

@interface TorrentDelegate : NSObject

+ (TorrentDelegate *)sharedInstance;
- (TorrentClient *)currentSelectedClient;
- (void) handleTorrentFile:(NSString *) fileName;

- (void) jobsCheckInvocation;

@property (nonatomic, strong) TorrentClient * currentSelectedClient;
@property (nonatomic, strong) NSArray * torrentSupportList;
@property (nonatomic, strong) NSDictionary * torrentDelegates;

@end
