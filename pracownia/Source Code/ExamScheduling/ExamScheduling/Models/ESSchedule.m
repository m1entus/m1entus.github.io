//
//  ESSchedule.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSchedule.h"
#import "ESCourse.h"

@interface ESSchedule ()
@property (nonatomic, strong, readwrite) NSNumber *quality;
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

// Key is slot number 0 - (totalNumberOfSlots-1), value is Array of coursesIds assigned for slot
@property (nonatomic, strong) NSMutableDictionary *slots;

// For performance
@property (nonatomic, strong) NSMutableDictionary *slotForCourseId;
@end

@implementation ESSchedule

- (NSNumber *)quality {
    if (!_quality) {
        // Calculate rank
        NSInteger nuberOfCourses = [ESCourse MR_countOfEntitiesWithContext:self.context];

        // Best distribution of schedules is that every slot has the same amount of courses
        CGFloat bestDistribution = (CGFloat)nuberOfCourses / [self.totalNumberOfSlots floatValue];
        _quality = @(1.0);

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
        _slots = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark - Private

- (void)generateSchedule {
    [self prepareSlots];

    NSArray *results = [ESCourse MR_findAll];
    [results enumerateObjectsUsingBlock:^(ESCourse *obj, NSUInteger idx, BOOL *stop) {
        NSInteger randomSlot = arc4random()%[self.totalNumberOfSlots integerValue];
        [self insertCourse:obj toSlot:@(randomSlot)];
    }];
}

- (void)prepareSlots {
    for (NSInteger i = 0; i < [self.totalNumberOfSlots integerValue]; i++) {
        self.slots[@(i)] = [NSMutableSet set];
    }
}

- (void)removeCourse:(ESCourse *)course fromSlot:(NSNumber *)slot {
    NSNumber *slotForCurrentCourse = self.slotForCourseId[course.courseId];
    if (slotForCurrentCourse) {
        NSMutableSet *setOfSlots = self.slots[slotForCurrentCourse];
        [setOfSlots removeObject:course.courseId];
    }
}

- (void)insertCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    NSParameterAssert(slot);
    NSMutableSet *setOfSlots = self.slots[slot];
    [setOfSlots addObject:course.courseId];
    self.slotForCourseId[course.courseId] = [slot copy];
}

- (void)reassignCourse:(ESCourse *)course toSlot:(NSNumber *)slot {
    [self removeCourse:course fromSlot:slot];
    [self insertCourse:course toSlot:slot];

}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ESSchedule *schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:[self.totalNumberOfSlots copyWithZone:zone] inContext:self.context];
    schedule.slots = [self.slots mutableCopyWithZone:zone];
    schedule.slotForCourseId = [self.slotForCourseId mutableCopyWithZone:zone];
    return schedule;
}

@end
