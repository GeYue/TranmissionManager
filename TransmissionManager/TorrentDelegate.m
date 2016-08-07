//
//  TorrentDelegate.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/19.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TSMessage.h"
#import "TorrentDelegate.h"

#import "Transmission.h"
#import "uTorrent.h"
#import "AppConfig.h"
#import "AFURLSessionManager.h"

@interface TorrentDelegate()

- (void) changeClient;

@end


@implementation TorrentDelegate

static TorrentDelegate * sharedInstance;

+ (void)initialize {
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedInstance = [TorrentDelegate new];
    }
}

+ (TorrentDelegate *) sharedInstance {
    return sharedInstance;
}

- (id) init {
    if (self = [super init]) {
        self.torrentSupportList = @[Transmission.class, uTorrent.class];
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        for (Class tclass in self.torrentSupportList) {
            [dict setObject:tclass forKey:[tclass name]];
        }
        self.torrentDelegates = dict;
        NSDictionary * cacheDict = [AppConfig.getInstance getValueForKey:@"runningConfig"];
        NSMutableDictionary * runCfgDict = (nil == cacheDict) ? [NSMutableDictionary dictionary] : [cacheDict mutableCopy];
        if (!cacheDict) {
            runCfgDict[@"clientname"] = @"Default";
            runCfgDict[@"server_type"] = @"Transmission";
            runCfgDict[@"refresh_connection_seconds"] = @2;
            runCfgDict[@"sort_by"] = @"Progress";
            runCfgDict[@"cell"] = @"Pretty";
            [AppConfig.getInstance settingValuesByObject:runCfgDict forKey:@"runningConfig"];
        }
        
        [self changeClient];
    }
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(changeClient) name:@"ChangedClient" object:nil];
    return self;
}

- (void) dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void) changeClient {
    NSLog(@"got notification \"ChangedClient\"");
    [self.currentSelectedClient becameIdle];
    NSDictionary * runConfigDict = [AppConfig.getInstance getValueForKey:@"runningConfig"];
    for (NSDictionary * dict in [AppConfig.getInstance getValueForKey:@"clients"]) {
        if ([dict[@"name"] isEqualToString:runConfigDict[@"clientname"]]) {
            for (NSString * name in self.torrentDelegates) {
                if ([name isEqualToString:dict[@"type"]]){
                    self.currentSelectedClient = [[self.torrentDelegates[name] alloc] init];
                    [AppConfig.getInstance settingCurrentClientCfgDict:dict];
                    break;
                }
            }
        }
    }
    [self.currentSelectedClient becameActive];
}

- (void) handleTorrentFile:(NSString *)fileName {
    if (fileName.length) {
        if ([[[fileName substringWithRange:NSMakeRange(0, 4)] lowercaseString] isEqualToString:@"http"]) {
            [self.currentSelectedClient handleTorrentURL:fileName];
        }
        else {
            [self.currentSelectedClient handleTorrentFile:fileName];
        }
    }
}

- (void) postClientConnectionInfo:(BOOL)bOnline {
    dispatch_async(dispatch_get_main_queue(), ^{
        [TorrentDelegate.sharedInstance.currentSelectedClient setHostOnline:bOnline];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"update_torrent_jobs_header" object:nil];
    });
}

- (void) jobsCheckInvocation {
    double refreshInterval = [[AppConfig.getInstance getValueForKey:@"runningConfig"][@"refresh_connection_seconds"] doubleValue];
    while (TRUE) {
        @autoreleasepool {
            double t = clock();
            NSMutableURLRequest * request = [TorrentDelegate.sharedInstance.currentSelectedClient requestForCheckTorrentJobs];
            if (request) {
                [request setTimeoutInterval:0x20];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc]
                                                initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    if (!error) {
                        NSData * data = (NSData *) responseObject;
                        NSMutableData * receivedData = [data mutableCopy];
                        
                        if (receivedData.length > 0) {
                            [self postClientConnectionInfo:TRUE];
                        };
                        
                        if ([TorrentDelegate.sharedInstance.currentSelectedClient isValidJobsData:receivedData]) {
                            TorrentDelegate.sharedInstance.currentSelectedClient.jobData = receivedData;
                            [TorrentDelegate.sharedInstance.currentSelectedClient handleTorrentJobs];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"update_torrent_jobs_table" object:nil];
                        } else {
                            NSString * utf8String = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
                            NSLog(@"Incorrect response to requeset for jobs data: %@", utf8String);
                        }
                    } else  {
                        NSLog(@"NSMutableURLRequest sent dataTaskWithRequest failed. %@ %@", error, [error userInfo]);
                    }
                }] resume];
            } else {
                [self postClientConnectionInfo:FALSE];
            }
            double elapsed = (clock() - t) / CLOCKS_PER_SEC;
            if (elapsed < refreshInterval) {
                NSLog(@"sleeping....");
                double intpart, fractpart;
                fractpart = modf(refreshInterval - elapsed, &intpart);
                struct timespec tspec = {
                    .tv_sec = intpart,
                    .tv_nsec = round(fractpart * 1e9)
                };
                nanosleep(&tspec, NULL);
            }
        }
    }
}

- (void) credentialsCheckInvocation {
    @autoreleasepool {
        NSMutableURLRequest * request = [TorrentDelegate.sharedInstance.currentSelectedClient requestForCheckTorrentJobs];
        if (!request) {
            [TSMessage showNotificationWithTitle:@"Connection request failed."
                                        subtitle:[TorrentDelegate.sharedInstance.currentSelectedClient getLastErrorDesc]
                                            type:TSMessageNotificationTypeError];
            return;
        };
        [request setTimeoutInterval:0x10];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc]
                                        initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            NSString * notifcation = nil;
            if (error) {
                notifcation = [error localizedDescription];
            } else {
                NSData * data = (NSData *) responseObject;
                NSMutableData * receivedData = [data mutableCopy];
                if (![TorrentDelegate.sharedInstance.currentSelectedClient isValidJobsData:receivedData]) {
                    notifcation = [TorrentDelegate.sharedInstance.currentSelectedClient parseTorrentFailure:receivedData];
                } else {
                    notifcation = @"No error info provided, are you sure that's the right port?";
                }
            }
            if (notifcation) {
                [TSMessage showNotificationWithTitle:@"Unable to authenticate" subtitle:notifcation type:TSMessageNotificationTypeError];
            }
        }];
    }
}

@end
