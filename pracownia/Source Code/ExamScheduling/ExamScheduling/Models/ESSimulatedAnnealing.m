//
//  RESimulatedAnnealing.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSimulatedAnnealing.h"
#import "ESCourse.h"

double const E = 2.718281828;

@interface ESSimulatedAnnealing ()
@property (nonatomic, readwrite, strong) ESSchedule *bestSchedule;
@property (nonatomic, strong) NSArray *allSortedCourses;

@property (nonatomic, strong) NSNumber *currentTemperature;
@end

@implementation ESSimulatedAnnealing

+ (instancetype)solverForContext:(NSManagedObjectContext *)context {
    return [[self alloc] initWithContext:context];
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _initialTemperature = @(0.93);
        _freezingTemperature = @(pow(2, -3));
        _phi = @(0.95);
        _perturb = @(0.1);
        _totalNumberOfSlots = @14;
        _context = context;
        _allSortedCourses = [ESCourse MR_findAllSortedBy:@"courseId" ascending:YES inContext:context];
    }
    return self;
}

- (void)prepareForSolve {
    self.bestSchedule = [ESSchedule randomScheduleWithTotalNumberOfSlots:self.totalNumberOfSlots inContext:self.context];
    self.currentTemperature = self.initialTemperature;
}

- (BOOL)shouldStopSolver {
    return [self.currentTemperature doubleValue] < [self.freezingTemperature doubleValue];
}

- (ESSchedule *)solve {
    [self prepareForSolve];

    NSInteger numberOfIterations = self.allSortedCourses.count * [self.totalNumberOfSlots integerValue];

    while (![self shouldStopSolver]) {
        @autoreleasepool {
            ESSchedule *schedule = self.bestSchedule;
            for (NSInteger i = 0; i < numberOfIterations; i++) {
                ESSchedule *perturbed = [schedule copy];
                NSInteger numberOfChangesToMake = arc4random() % (NSInteger)((self.allSortedCourses.count * [self.perturb doubleValue]) + 1);
                for (NSInteger i = 0; i < numberOfChangesToMake; i++) {
                    ESCourse *randomCourse = self.allSortedCourses[(NSInteger)arc4random() % self.allSortedCourses.count];
                    NSInteger randomSlot = arc4random()%[self.totalNumberOfSlots integerValue];
                    [perturbed reassignCourse:randomCourse toSlot:@(randomSlot)];
                }

                double qualityDifference = [perturbed.quality doubleValue] - [schedule.quality doubleValue];

                double randomDouble = (double)(arc4random() % ((unsigned)RAND_MAX + 1)) / (double)RAND_MAX;
                if (qualityDifference < 0) {
                    schedule = perturbed;
                } else if ( randomDouble < pow(E, -qualityDifference / [self.currentTemperature doubleValue])) {
                    schedule = perturbed;
                }

                if ([schedule.quality doubleValue] < [self.bestSchedule.quality doubleValue]) {
                    self.bestSchedule = schedule;
                }
            }
            self.currentTemperature = @([self.currentTemperature doubleValue] * [self.phi doubleValue]);
        }
    }

    return self.bestSchedule;
}

- (void)solveWithCompletionHandler:(void(^)(ESSchedule *bestSchedule))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ESSchedule *schedule = [self solve];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(schedule);
            }
        });
    });
}

@end
