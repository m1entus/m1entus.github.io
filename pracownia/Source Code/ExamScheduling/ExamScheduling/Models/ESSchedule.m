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

CGFloat const ESScheduleVariantWeight= 1.0;
CGFloat const ESScheduleVariantWeightThreshold = 100.0;

CGFloat const ESSchedulePenaltyCounterSimultaneousExams = CGFLOAT_MAX;
CGFloat const ESSchedulePenaltyCounterConsecutiveExams = 2.0;
CGFloat const ESSchedulePenaltyCounterMoreThanTwoPerDayExams = 5.0;

@interface ESSchedule ()
@property (nonatomic, strong, readwrite) NSNumber *quality;
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

// Key is slot number 0 - (totalNumberOfSlots-1), value is Array of coursesIds assigned for slot
@property (nonatomic, strong) NSDictionary *slots;

// Key: courseId, Value: slot - this is for performance
@property (nonatomic, strong) NSDictionary *slotForCourseId;
@end

@implementation ESSchedule

- (NSNumber *)quality {
    if (!_quality) {
        // Calculate rank
        NSInteger numberOfCourses = [ESCourse MR_countOfEntitiesWithContext:self.context];

        // Best distribution of schedules is that every slot has the same amount of courses
        CGFloat bestDistribution = (CGFloat)numberOfCourses / [self.totalNumberOfSlots floatValue];
        __block double variant = 0.0;


        [self.slots enumerateKeysAndObjectsUsingBlock:^(NSNumber *slot, NSMutableSet *coursesInSlot, BOOL *stop) {
            variant += pow((double)(coursesInSlot.count - bestDistribution), 2);
        }];
        variant /= (double)self.slots.count;


        __block double rank = 0;

        if (variant <= ESScheduleVariantWeightThreshold) {
            rank = variant * ESScheduleVariantWeight;

            NSArray *students = [ESStudent MR_findAllInContext:self.context];
            [students enumerateObjectsUsingBlock:^(ESStudent *student, NSUInteger idx, BOOL *stop) {
                rank += [[student qualityOfSchedule:self] doubleValue];
                if (rank >= CGFLOAT_MAX) {
                    *stop = YES;
                }
            }];
        } else {
            rank = CGFLOAT_MAX;
        }

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
        _slotForCourseId = [NSDictionary dictionary];
        _slots = [NSDictionary dictionary];
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
    NSMutableDictionary *slots = [NSMutableDictionary dictionaryWithCapacity:[self.totalNumberOfSlots integerValue]];
    for (NSInteger i = 0; i < [self.totalNumberOfSlots integerValue]; i++) {
        slots[@(i)] = [NSMutableSet set];
    }
    self.slots = [slots copy];
}

- (NSNumber *)slotForCourse:(ESCourse *)course {
    return self.slotForCourseId[course.courseId];
}

- (void)removeCourse:(ESCourse *)course fromSlot:(NSNumber *)slot {
    NSNumber *slotForCurrentCourse = [self slotForCourse:course];
    NSParameterAssert(slotForCurrentCourse);
    if (slotForCurrentCourse) {
        NSMutableSet *setOfSlots = self.slots[slotForCurrentCourse];
        [setOfSlots removeObject:course.courseId];

        NSMutableDictionary *slots = [self.slots mutableCopy];
        slots[slotForCurrentCourse] = setOfSlots;
        self.slots = [slots copy];
    }
}

- (void)insertCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    NSParameterAssert(slot);
    NSMutableSet *setOfSlots = self.slots[slot];
    [setOfSlots addObject:course.courseId];

    NSMutableDictionary *slots = [self.slots mutableCopy];
    slots[slot] = setOfSlots;
    self.slots = [slots copy];

    NSMutableDictionary *slotForCourseId = [self.slotForCourseId mutableCopy];
    slotForCourseId[course.courseId] = [slot copy];
    self.slotForCourseId = [slotForCourseId copy];
}

- (void)reassignCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    [self removeCourse:course fromSlot:slot];
    [self insertCourse:course toSlot:slot];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ESSchedule *schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:[self.totalNumberOfSlots copyWithZone:zone] inContext:self.context];
    schedule.slots = [self.slots copyWithZone:zone];
    schedule.slotForCourseId = [self.slotForCourseId copyWithZone:zone];
    return schedule;
}

@end
