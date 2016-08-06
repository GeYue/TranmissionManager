//
//  NSNumber+StringCategory.m
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/28.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import "NSNumber+StringCategory.h"

@implementation NSNumber (SignificantDates)

- (NSString *)ETAString
{
    NSMutableArray * retVal = [NSMutableArray new];
    if ([self integerValue] == -1 || [self unsignedIntegerValue] == 1827387392)
    {
        return @"∞";
    }
    else if (![self isZero])
    {
        NSNumber * seconds = @([self unsignedIntegerValue] % 60);
        NSUInteger minutes = [self unsignedIntegerValue] / 60;
        NSUInteger hours = minutes / 60;
        NSUInteger days = hours / 24;
        NSUInteger weeks = days / 7;
        NSUInteger months = weeks / 52;
        NSUInteger years = months / 12;
        
        NSArray * numbers = @[@(years), @(weeks % 52), @(days % 7), @(hours % 24), @(minutes % 60), seconds];
        
        int counter = 0;
        for (NSNumber * number in numbers)
        {
            if ([number unsignedIntegerValue])
            {
                [retVal addObject:[NSString stringWithFormat:@"%@%@", number, @[@"y", @"w", @"d", @"h", @"m", @"s"][counter]]];
                if ([retVal count] > 1)
                {
                    return [retVal componentsJoinedByString:@" "];
                }
            }
            ++counter;
        }
    }
    return [retVal count] ? retVal[0] : @"";
}

- (BOOL)isZero
{
    return self.doubleValue == 0;
}

- (NSString *)transferRateString
{
    return [self.sizeString stringByAppendingString:@"/s"];
}

- (NSString *)sizeString
{
    if (self.longLongValue)
    {
        switch ((unsigned)log2(self.doubleValue) / 10)
        {
            case 1:
                return [NSString stringWithFormat:@"%.1f KiB", self.doubleValue / (1ULL << 10)];
            case 2:
                return [NSString stringWithFormat:@"%.1f MiB", self.doubleValue / (1ULL << 20)];
            case 3:
                return [NSString stringWithFormat:@"%.1f GiB", self.doubleValue / (1ULL << 30)];
            case 4:
                return [NSString stringWithFormat:@"%.1f TiB", self.doubleValue / (1ULL << 40)];
            case 5:
                return [NSString stringWithFormat:@"%.1f PiB", self.doubleValue / (1ULL << 50)];
            case 6:
                return [NSString stringWithFormat:@"%.1f EiB", self.doubleValue / (1ULL << 60)];
        }
    }
    return [NSString stringWithFormat:@"%lld B", self.longLongValue];
}

@end
