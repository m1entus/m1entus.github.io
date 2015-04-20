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
#import "ESDatabaseDataCache.h"

CGFloat const ESScheduleVariantWeight= 1.0;
CGFloat const ESScheduleVariantWeightThreshold = 100.0;

// Hard constraint
double const ESSchedulePenaltyCounterSimultaneousExams = 40000000.00;

// Soft constraint
CGFloat const ESSchedulePenaltyCounterConsecutiveExams[5] = {16, 8, 4, 2, 1};

@interface ESSchedule ()
@property (nonatomic, strong, readwrite) NSNumber *quality;
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

// Key is slot number 0 - (totalNumberOfSlots-1), value is Array of coursesIds assigned for slot
//@property (nonatomic, strong) NSMutableDictionary *slots;

// Key: courseId, Value: slot - this is for performance
@property (nonatomic, strong) NSMutableDictionary *slotForCourseId;
@property (nonatomic, strong) NSMutableArray *slotCounter;
@end

@implementation ESSchedule

- (NSNumber *)quality {
    if (!_quality) {

//        NSInteger numberOfCourses = [ESDatabaseDataCache sharedInstance].courses.count;

        // Best distribution of schedules is that every slot has the same amount of courses
//        CGFloat bestDistribution = (CGFloat)numberOfCourses / [self.totalNumberOfSlots floatValue];
//        __block double variant = 0.0;
//
//
//        [self.slotCounter enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
//            variant += pow((double)([obj integerValue] - bestDistribution), 2);
//        }];
//        variant /= (double)self.slotForCourseId.count;
//

        double rank = 0;

        NSArray *students = [ESDatabaseDataCache sharedInstance].students;

        NSNumber *currentBestScheduleQuality = [self.dataSource currentBestScheduleQualityForSchedule:self];
        double currentBestScheduleQualityDoubleValue = [currentBestScheduleQuality doubleValue];

//        if (variant <= ESScheduleVariantWeightThreshold) {
//            rank = variant * ESScheduleVariantWeight;

            for (ESStudent *student in students) {
                double studentRank = [[student qualityOfSchedule:self] doubleValue];
                rank += (studentRank/students.count);
                //optimization
                if (currentBestScheduleQuality && currentBestScheduleQualityDoubleValue < rank) {
                    _quality = @(rank);
                    return _quality;
                }
            }
//        } else {
//            rank = CGFLOAT_MAX;
//        }

        _quality = @(rank);

    }
    return _quality;
}

+ (instancetype)randomScheduleWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context {
    ESSchedule *schedule = [[self alloc] initWithTotalNumberOfSlots:numberOfSlots inContext:context];
    [schedule generateSchedule];

    return schedule;
}

- (instancetype)initWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        NSParameterAssert(numberOfSlots);

        _totalNumberOfSlots = numberOfSlots;
        _context = context;
        _slotForCourseId = [NSMutableDictionary dictionary];
        _slotCounter = [NSMutableArray arrayWithCapacity:[self.totalNumberOfSlots integerValue]];
        for (NSInteger i = 0; i < [self.totalNumberOfSlots integerValue]; i++) {
            _slotCounter[i] = @0;
        }
//        _slots = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Private

- (void)generateSchedule {
    [self prepareSlots];

    NSArray *results = [ESCourse MR_findAllInContext:self.context];
    [results enumerateObjectsUsingBlock:^(ESCourse *obj, NSUInteger idx, BOOL *stop) {
        NSInteger randomSlot = arc4random()%[self.totalNumberOfSlots integerValue];
        [self insertCourse:obj toSlot:@(randomSlot)];
    }];

}

- (void)prepareSlots {
//    NSMutableDictionary *slots = [NSMutableDictionary dictionaryWithCapacity:[self.totalNumberOfSlots integerValue]];
//    for (NSInteger i = 0; i < [self.totalNumberOfSlots integerValue]; i++) {
//        slots[@(i)] = [NSMutableArray array];
//    }
//    self.slots = [slots copy];
}

- (NSNumber *)slotForCourse:(ESCourse *)course {
    return self.slotForCourseId[course.courseId];
}

- (void)removeCourse:(ESCourse *)course {
    NSNumber *slotForCurrentCourse = [self slotForCourse:course];
    NSNumber *slotCount = self.slotCounter[[slotForCurrentCourse integerValue]];
    slotCount = @([slotCount integerValue]-1);
    self.slotCounter[[slotForCurrentCourse integerValue]] = slotCount;

//    NSMutableArray *setOfSlots = self.slots[slotForCurrentCourse];
//    [setOfSlots removeObject:course.courseId];

    [self.slotForCourseId removeObjectForKey:course.courseId];
}

- (void)insertCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    NSParameterAssert(slot);

//    NSMutableArray *setOfSlots = self.slots[slot];
//    [setOfSlots addObject:course.courseId];

    self.slotForCourseId[course.courseId] = slot;

    NSNumber *slotCount = self.slotCounter[[slot integerValue]];
    slotCount = @([slotCount integerValue]+1);
    self.slotCounter[[slot integerValue]] = slotCount;

}

- (void)reassignCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    [self removeCourse:course];
    [self insertCourse:course toSlot:@([slot integerValue] % [self.totalNumberOfSlots integerValue])];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ESSchedule *schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:[self.totalNumberOfSlots copyWithZone:zone] inContext:self.context];

    schedule.slotForCourseId = [self.slotForCourseId mutableCopyWithZone:zone];
    schedule.slotCounter = [self.slotCounter mutableCopyWithZone:zone];

    return schedule;
}

@end
