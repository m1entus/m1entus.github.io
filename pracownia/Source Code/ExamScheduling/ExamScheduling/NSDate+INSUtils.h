//
//  NSDate+INSUtils.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 01.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (INSUtils)

- (BOOL)ins_isLaterThan:(NSDate *)date;
- (BOOL)ins_isEarlierThan:(NSDate *)date;
- (BOOL)ins_isLaterThanOrEqualTo:(NSDate *)date;
- (BOOL)ins_isEarlierThanOrEqualTo:(NSDate *)date;

- (NSDate *)ins_dateByAddingHours:(NSInteger)hour;
- (NSDate *)ins_dateWithoutMinutesAndSeconds;
+ (NSDate *)ins_dateInYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
@end
