//
//  NSString+StringCategory.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/26.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (StringHandler)
+ (NSString *) getStringBetween:(NSString *)key
                      andString:(NSString *)terminator
                     fromString:(NSString *)baseString;

- (NSString *) getStringBetween:(NSString *)key andString:(NSString *)terminator;
@end
