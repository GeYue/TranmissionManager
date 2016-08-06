//
//  AppConfig.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/24.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConfig : NSObject

+ (AppConfig *) getInstance;

- (void) settingValuesByObject:(id)valueObject forKey:(NSString *)key;
- (id) getValueForKey:(NSString *)key;
- (void) settingVauesByDictionary:(NSDictionary *)dict forKey:(NSString *)key;
- (void) settingCurrentClientCfgDict:(NSDictionary *)dict;

@property (nonatomic, strong) NSMutableDictionary * currentClientCfgDict;

@end
