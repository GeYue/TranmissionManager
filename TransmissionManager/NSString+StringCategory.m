//
//  NSString+StringCategory.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/26.
//  Copyright © 2016年 葛岳. All rights reserved.
//
#import "NSString+StringCategory.h"

@implementation NSString (StringHandler)

+ (NSString *) getStringBetween:(NSString *)key
                      andString:(NSString *)terminator
                     fromString:(NSString *)baseString
{
    NSString * retVal = @"";
    terminator = terminator ? terminator : @"";
    
    long loc1 = [baseString rangeOfString:key].location;
    long loc2 = 0;
    
    if (loc1 != NSNotFound)
    {
        loc2 = [[baseString substringWithRange:NSMakeRange(loc1 + [key length], [baseString length] - (loc1 + [key length]))] rangeOfString:terminator].location + loc1 + [key length];
    }
    
    if (loc1 != NSNotFound && loc2 != NSNotFound && loc2 > loc1)
    {
        NSRange range1 = [baseString rangeOfString:key];
        range1.location += range1.length;
        range1.length = baseString.length - range1.location;
        NSString * rangeStr = [baseString substringWithRange:range1];
        NSRange range2 = [rangeStr rangeOfString:terminator];
        retVal = [baseString substringWithRange:NSMakeRange(range1.location, range2.location)];
    }
    else if (loc1 != NSNotFound)
    {
        NSRange range1 = [baseString rangeOfString:key];
        range1.location += range1.length;
        range1.length = baseString.length - range1.location;
        retVal = [baseString substringWithRange:range1];
    }
    
    return retVal;
}

- (NSString *) getStringBetween:(NSString *)key andString:(NSString *)terminator
{
    return [NSString getStringBetween:key andString:terminator fromString:self];
}

@end

