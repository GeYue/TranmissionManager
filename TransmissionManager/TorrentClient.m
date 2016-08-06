//
//  TorrentClient.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/19.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "TorrentClient.h"
#import "AppConfig.h"

@interface TorrentClient ()

- (void) handletorrentData: (NSData *)data withURL:(NSURL *)fileURL;

@end

@implementation TorrentClient

-(id) init {
    if (self = [super init]) {
        currentJobsDict = [[NSMutableDictionary alloc] init];
        self.jobData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void) becameIdle {
    
}

- (void) becameActive {
    
}

- (NSDictionary *) getJobsDict {
    return currentJobsDict;
}

- (NSString *) getBasedURL {
    NSString * urlString;
    NSString * port = [AppConfig.getInstance currentClientCfgDict][@"port"];
    NSString * username = [AppConfig.getInstance currentClientCfgDict][@"username"];
    NSString * password = [AppConfig.getInstance currentClientCfgDict][@"password"];
    NSString * url = [AppConfig.getInstance currentClientCfgDict][@"url"];
    
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];

    NSString * strHyerTextString = [NSString stringWithFormat:@"http%@://",
                                    [[AppConfig.getInstance currentClientCfgDict][@"use_ssl"] boolValue] ? @"s" : @""];
    if (username.length && password.length){
        urlString = [NSString stringWithFormat:@"%@%@:%@@%@:%@", strHyerTextString, username, password, url, port];
    } else if (username.length) {
        urlString = [NSString stringWithFormat:@"%@%@@%@:%@", strHyerTextString, username, url, port];
    } else {
        urlString = [NSString stringWithFormat:@"%@%@:%@", strHyerTextString, url, port];
    }

    return urlString;
}

- (NSString *) getURLAppendString {
    NSLog(@"Incomplete implementation of %s", __PRETTY_FUNCTION__);
    return nil;
}

- (NSString *) getAppendedURL {
    return [[self getBasedURL] stringByAppendingString:self.getURLAppendString];
    
}

- (NSMutableURLRequest *) requestForCheckTorrentJobs {
    return nil;    
}

- (void) handleTorrentJobs {
    previousJobsDict = [NSDictionary dictionaryWithDictionary:currentJobsDict];
    currentJobsDict = [NSMutableDictionary dictionaryWithDictionary:self.virtualHandleTorrentJobs];
}

- (BOOL) isValidJobsData:(NSData *)data {
    return NO;
}

- (void) insertTorrentJobsDictWithArray:(NSArray *)array intoDict:(NSMutableDictionary *)dict {
    NSMutableDictionary * torrentDict = [NSMutableDictionary new];
    
    for (id item in array)
    {
        if (!item)
        {
            return;
        }
    }
    switch ([array count])
    {
        default:
            [torrentDict setObject:array[16] forKey:@"dateDone"];
        case 16:
            [torrentDict setObject:array[15] forKey:@"dateAdded"];
        case 15:
            [torrentDict setObject:array[14] forKey:@"ratio"];
        case 14:
            [torrentDict setObject:array[13] forKey:@"rawUploadSpeed"];
        case 13:
            [torrentDict setObject:array[12] forKey:@"rawDownloadSpeed"];
        case 12:
            [torrentDict setObject:[array[11] description] forKey:@"seedsConnected"];
        case 11:
            [torrentDict setObject:[array[10] description] forKey:@"peersConnected"];
        case 10:
            [torrentDict setObject:array[9] forKey:@"size"];
        case 9:
            [torrentDict setObject:array[8] forKey:@"uploaded"];
        case 8:
            [torrentDict setObject:array[7] forKey:@"downloaded"];
        case 7:
            [torrentDict setObject:array[6] forKey:@"ETA"];
        case 6:
            [torrentDict setObject:array[5] forKey:@"uploadSpeed"];
        case 5:
            [torrentDict setObject:array[4] forKey:@"downloadSpeed"];
        case 4:
            [torrentDict setObject:array[3] forKey:@"status"];
        case 3:
            [torrentDict setObject:array[2] forKey:@"progress"];
        case 2:
            [torrentDict setObject:array[1] forKey:@"name"];
        case 1:
            [torrentDict setObject:[array[0] uppercaseString] forKey:@"hash"];
            break;
        case 0:
            return;
    }
    [dict setObject:torrentDict forKey:[array[0] uppercaseString]];
}

- (NSDictionary *) virtualHandleTorrentJobs {
    return nil;
}

- (id) getTorrentJobs {
    return nil;
}

@end
