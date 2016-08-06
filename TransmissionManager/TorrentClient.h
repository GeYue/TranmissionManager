//
//  TorrentClient.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/19.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface TorrentClient : NSObject
{
    //TorrentFileHandler * torrentFileHandler;
    NSDictionary * previousJobsDict;
    NSMutableDictionary * currentJobsDict;
    
    BOOL hostOnline;
}

@property (nonatomic, strong) NSData * jobData;
@property (nonatomic, strong, setter=setTemporaryDeletedJobs:, getter=getTemporaryDeletedJobs) NSMutableDictionary * temporaryDeleteJobs;
@property (nonatomic, weak, setter=showNotification:) UIViewController * notificationViewController;

- (void) addTemporaryDeleteJobs:(NSUInteger)objs forKey:(NSString *)key;

#pragma mark - Virtual Functions I - properties
+ (NSString *) name;
+ (NSNumber *) completeNumber;
+ (NSString *) defaultPort;
+ (BOOL) supportsRelativePath;
+ (BOOL) supportsLabels;
+ (BOOL) supportsDirectoryChoice;

- (BOOL) isValidJobsData:(NSData *) data;

- (void) becameIdle;
- (void) becameActive;
- (void) willExit;

#pragma mark - Virtual Functions II - actions
- (void) handleTorrentFile:(NSString *)filePath;
- (void) handleTorrentURL:(NSString *)fileURL;
- (void) pauseTorrent:(NSString *)hash;
- (void) resumeTorrent:(NSString *)hash;
- (void) removeTorrent:(NSString *)hash removeWithData:(BOOL)bRemoveData;
- (void) pauseAllTorrents;
- (void) resumeAllTorrents;

- (void) handleTorrentJobs;
- (void) showNotification:(UIViewController *) viewController;
- (void) insertTorrentJobsDictWithArray:(NSArray *)array intoDict:(NSMutableDictionary *)dict;

#pragma mark - memeber functions
- (NSString *) getBasedURL;
- (NSString *) getAppendedURL;
- (NSDictionary *) getJobsDict;
- (NSMutableURLRequest *) requestForCheckTorrentJobs;


@end
