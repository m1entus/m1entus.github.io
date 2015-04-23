//
//  RESimulatedAnnealing.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSimulatedAnnealingMethodology.h"
#import "ESCourse.h"
#import "ESDataCache.h"
#import "NSNumber+Random.h"

double const E = 2.718281828;

@interface ESSimulatedAnnealingMethodology () <ESScheduleDataSource>
@property (nonatomic, readwrite, strong) ESSchedule *bestSchedule;
@property (nonatomic, strong) NSNumber *currentTemperature;
@end

@implementation ESSimulatedAnnealingMethodology

- (instancetype)init {
    if (self = [super init]) {
        _initialTemperature = @(1200.95);
//        _initialTemperature = @(0.95);
        _freezingTemperature = @(pow(2, -10));
//        _freezingTemperature = @(pow(2, -3));
        _phi = @(0.95);
        _perturb = @(0.1);
        _totalNumberOfSlots = @14;
    }
    return self;
}

- (void)prepareForSolve {
    self.bestSchedule = [ESSchedule randomScheduleWithTotalNumberOfSlots:self.totalNumberOfSlots];
    self.currentTemperature = self.initialTemperature;
}

- (BOOL)shouldStopSolver {
    return [self.currentTemperature doubleValue] < [self.freezingTemperature doubleValue];
}

- (ESSchedule *)solve {
    [self prepareForSolve];

    NSInteger numberOfIterations = [ESDataCache sharedInstance].courses.count * [self.totalNumberOfSlots integerValue];

    while (![self shouldStopSolver]) {
        ESSchedule *schedule = self.bestSchedule;
        for (NSInteger i = 0; i < numberOfIterations; i++) {
            @autoreleasepool {
                ESSchedule *perturbed = [schedule copy];
                perturbed.dataSource = self;
                NSInteger numberOfChangesToMake = arc4random() % (NSInteger)(([ESDataCache sharedInstance].courses.count * [self.perturb doubleValue]) + 1);
                for (NSInteger i = 0; i < numberOfChangesToMake; i++) {
                    NSArray *courses = [ESDataCache sharedInstance].courses;
                    ESCourse *randomCourse = courses[(NSInteger)arc4random() % courses.count];
                    NSInteger randomSlot = arc4random()%[self.totalNumberOfSlots integerValue];
                    [perturbed reassignCourse:randomCourse toSlot:@(randomSlot)];
                }

                double peturbedQuality = [perturbed.quality doubleValue];
                double scheduleQuality = [schedule.quality doubleValue];

                double qualityDifference = peturbedQuality - scheduleQuality;

                double randomDouble = [[NSNumber randomDouble] doubleValue];
                if (qualityDifference < 0) {
                    schedule = perturbed;
                } else if ( randomDouble < pow(E, -qualityDifference / [self.currentTemperature doubleValue])) {
                    schedule = perturbed;
                }

                if ([schedule.quality doubleValue] < [self.bestSchedule.quality doubleValue]) {
                    self.bestSchedule = schedule;

                    NSLog(@"Slots: %@\n", schedule.slotForCourseId);
                    NSLog(@"Current Temperature: %@\n",self.currentTemperature);
                    NSLog(@"QUALITY: %@\n",schedule.quality);
                }
            }
        }
        self.currentTemperature = @([self.currentTemperature doubleValue] * [self.phi doubleValue]);
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

- (NSNumber *)currentBestScheduleQualityForSchedule:(ESSchedule *)schedule {
    return self.bestSchedule.quality;
}

@end
