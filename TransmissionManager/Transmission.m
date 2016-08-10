//
//  Transmission.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/23.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "Transmission.h"
#import "AFURLRequestSerialization.h"
#import "NSString+StringCategory.h"
#import "NSNumber+StringCategory.h"

@implementation Transmission

+ (NSString *) name {
    return @"Transmission";
}

+ (NSNumber *) completeNumber {
    return @1;
}

- (NSString *) getURLAppendString {
    return @"/transmission/rpc/";
}

- (NSMutableURLRequest *) requestForCheckTorrentJobs {
    NSString * url = [self getAppendedURL];

    __block NSString * localToken = nil;
    __block NSString * errorDesc = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableURLRequest * oneReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:oneReq
                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                         if (!error) {
                                             NSString * utf8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                             localToken = [utf8String getStringBetween:@"X-Transmission-Session-Id: " andString:@"</code>"];
                                             dispatch_semaphore_signal(semaphore);
                                         } else {
                                             NSLog(@"Error: %@ %@", error, [error userInfo]);
                                             errorDesc = [error localizedDescription];
                                             dispatch_semaphore_signal(semaphore);
                                         }
                                     }] resume];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (!localToken) {
        [self setLastErrorDesc:errorDesc];
        return nil;
    }
    NSDictionary * parametersDict = @{@"method":@"torrent-get", @"arguments":@{@"fields":@[@"hashString", @"name", @"percentDone", @"status", @"sizeWhenDone", @"downloadedEver", @"uploadedEver", @"peersGettingFromUs", @"peersSendingToUs", @"rateDownload", @"rateUpload", @"eta", @"uploadRatio", @"addedDate", @"doneDate"]}};

    NSMutableURLRequest * req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url
                                                                             parameters:parametersDict error:nil];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:localToken forHTTPHeaderField:@"X-Transmission-Session-Id"];

    return req;
}

- (BOOL) isValidJobsData:(NSData *)data {
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if ([JSON respondsToSelector:@selector(objectForKey:)]) {
        if ([JSON[@"arguments"] respondsToSelector:@selector(objectForKey:)]) {
            if ([[JSON[@"arguments"] allKeys] containsObject:@"torrents"]) {
                return YES;
            }
        }
    }
    return NO;  
}

- (NSString *) parseTorrentFailure:(NSData *) data {
    NSError * error = nil;
    id JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error)
    {
        NSString * utf8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([utf8String rangeOfString:@"<h1>401: Unauthorized</h1>"].location != NSNotFound)
        {
            return @"Incorrect or missing user credentials.";
        }
    }
    
    return [JSON respondsToSelector:@selector(objectForKey:)] ? [JSON objectForKey:@"result"] : nil;
}

- (NSDictionary *) getTorrentJobs {
    id JSON = [NSJSONSerialization JSONObjectWithData:self.jobData options:0 error:nil];
    if ([JSON respondsToSelector:@selector(objectForKey:)]) {
        if ([[JSON[@"arguments"] allKeys] containsObject:@"torrents"]) {
            return JSON[@"arguments"][@"torrents"];
        }
    }
    return nil;
}

- (NSDictionary *) virtualHandleTorrentJobs {
    NSMutableDictionary * tempDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary * dict in [self getTorrentJobs]) {
        NSString * status = @"";
        switch ([dict[@"status"] intValue]) {
            case 0:
                status = @"Paused";
                break;
            case 3:
                status = @"Download Queued";
                break;
            case 4:
                status = @"Downloading";
                break;
            case 6:
                status = @"Seeding";
                break;
            default:
                break;
        }
        
        NSString * ETA = [dict[@"eta"] intValue] != -2 ? [dict[@"eta"] ETAString] : @"∞";
        if (dict[@"hashString"]) {
            [self insertTorrentJobsDictWithArray:@[dict[@"hashString"], dict[@"name"], dict[@"percentDone"], status, [dict[@"rateDownload"] transferRateString], [dict[@"rateUpload"] transferRateString], ETA, [dict[@"downloadedEver"] sizeString], [dict[@"uploadedEver"] sizeString], dict[@"sizeWhenDone"], dict[@"peersGettingFromUs"], dict[@"peersSendingToUs"], dict[@"rateDownload"], dict[@"rateUpload"], dict[@"uploadRatio"], dict[@"addedDate"], dict[@"doneDate"]]
                                        intoDict:tempDict];
        }
    }
    return tempDict;
}

- (void) pauseTorrent:(NSString *)hash {
    
}

- (void) resumeTorrent:(NSString *)hash {
    
}

- (void) removeTorrent:(NSString *)hash removeWithData:(BOOL)bRemoveData {
    
}

@end
