//
//  ESSchedule.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSchedule.h"
#import "ESCourse.h"
#import "ESStudent.h"
#import "ESDataCache.h"

// Hard constraint
double const ESSchedulePenaltyCounterSimultaneousExams = 4000000.00;

// Soft constraint
CGFloat const ESSchedulePenaltyCounterConsecutiveExams[5] = {16, 8, 4, 2, 1};

@interface ESSchedule ()
@property (nonatomic, strong, readwrite) NSNumber *quality;
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

@property (nonatomic, strong) NSMutableDictionary *slotForCourseId; //<NSString, NSNumber>
@end

@implementation ESSchedule

- (NSNumber *)quality {
    if (!_quality) {

        __block double rank = 0;

        NSNumber *currentBestScheduleQuality = [self.dataSource currentBestScheduleQualityForSchedule:self];
        double currentBestScheduleQualityDoubleValue = [currentBestScheduleQuality doubleValue];

        NSArray *students = [ESDataCache sharedInstance].students;

        NSLock *lock = [[NSLock alloc] init];

        [students enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(ESStudent *student, NSUInteger idx, BOOL *stop) {

            [student qualityOfSchedule:self withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
                [lock lock];
                if (simultaneousExamsPenalty) {
                    rank += simultaneousExamsPenalty;
                } else {
                    rank += (studentPenalty/students.count);
                }
                [lock unlock];
            }];

            //optimization
            if (currentBestScheduleQuality && currentBestScheduleQualityDoubleValue < rank) {
                *stop = YES;
            }
        }];

        _quality = @(rank);

    }
    return _quality;
}

+ (instancetype)randomScheduleWithTotalNumberOfSlots:(NSNumber *)numberOfSlots {
    ESSchedule *schedule = [[self alloc] initWithTotalNumberOfSlots:numberOfSlots];
    [schedule generateSchedule];

    return schedule;
}

- (instancetype)initWithTotalNumberOfSlots:(NSNumber *)numberOfSlots {
    if (self = [super init]) {
        NSParameterAssert(numberOfSlots);

        _totalNumberOfSlots = numberOfSlots;
        _slotForCourseId = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Private

- (void)generateSchedule {
    NSArray *results = [ESDataCache sharedInstance].courses;
    [results enumerateObjectsUsingBlock:^(ESCourse *obj, NSUInteger idx, BOOL *stop) {
        NSInteger randomSlot = arc4random()%[self.totalNumberOfSlots integerValue];
        [self insertCourse:obj toSlot:@(randomSlot)];
    }];

}

- (NSNumber *)slotForCourse:(ESCourse *)course {
    return self.slotForCourseId[course.courseId];
}

- (void)removeCourse:(ESCourse *)course {
    [self.slotForCourseId removeObjectForKey:course.courseId];
}

- (void)insertCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    NSParameterAssert(slot);

    self.slotForCourseId[course.courseId] = slot;
}

- (void)reassignCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    [self removeCourse:course];
    [self insertCourse:course toSlot:@([slot integerValue] % [self.totalNumberOfSlots integerValue])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ESSchedule *schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:[self.totalNumberOfSlots copyWithZone:zone]];

    schedule.slotForCourseId = [self.slotForCourseId mutableCopyWithZone:zone];

    return schedule;
}

@end
