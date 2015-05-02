//
//  NSDate+INSUtils.m
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 01.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "NSDate+INSUtils.h"

@implementation NSDate (INSUtils)

- (BOOL)ins_isLaterThan:(NSDate *)date
{
    if (self.timeIntervalSince1970 > date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isEarlierThan:(NSDate *)date
{
    if (self.timeIntervalSince1970 < date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isLaterThanOrEqualTo:(NSDate *)date
{
    if (self.timeIntervalSince1970 >= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}
- (BOOL)ins_isEarlierThanOrEqualTo:(NSDate *)date
{
    if (self.timeIntervalSince1970 <= date.timeIntervalSince1970) {
        return YES;
    }
    return NO;
}

- (NSDate *)ins_dateByAddingHours:(NSInteger)hour
{
    return [self dateByAddingTimeInterval:(hour * 3600)];
}

- (NSDate *)ins_dateWithoutMinutesAndSeconds
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];

    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit
                                                   fromDate:self];
    [dateComponents setMinute:0];
    [dateComponents setSecond:0];

    return [calendar dateFromComponents:dateComponents];
}

+ (NSDate *)ins_dateInYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    [components setHour:hour];
    [components setMinute:minute];
    [components setSecond:0];

    return [calendar dateFromComponents:components];
}

@end
