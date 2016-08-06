//
//  AppConfig.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/24.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "AppConfig.h"
@interface AppConfig ()

@end

@implementation AppConfig

static AppConfig * sharedInstance;

+ (AppConfig *) getInstance {
    if (!sharedInstance) {
        sharedInstance = [[AppConfig alloc] init];
    }
    
    return sharedInstance;
}

- (void) settingValuesByObject:(id)valueObject forKey:(NSString *)key {
    if (key.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:valueObject forKey:key];
    }
}

- (void) settingVauesByDictionary:(NSDictionary *)dict forKey:(NSString *)key {
    if (key.length > 0) {
        NSMutableDictionary * sys_dict = [[self getValueForKey:key] mutableCopy];
        for (NSString * dictkey in dict.allKeys) {
            sys_dict[dictkey] = dict[dictkey];
        }
        [self settingValuesByObject:sys_dict forKey:key];
    }
}

- (id) getValueForKey:(NSString *)key {
    if (key.length > 0) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    else
        return nil;
}

- (void) settingCurrentClientCfgDict:(NSDictionary *)dict {
    self.currentClientCfgDict = [dict mutableCopy];
}
@end
