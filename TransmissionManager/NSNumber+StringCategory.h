//
//  NSNumber+StringCategory.h
//  TransmissionManager
//
//  Created by 葛岳 on 16/7/28.
//  Copyright © 2016年 葛岳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (SignificantDates)
- (NSString *)ETAString;
- (BOOL)isZero;
- (NSString *)transferRateString;
- (NSString *)sizeString;
@end