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
@property (nonatomic, strong) ESDataCache *cache;
@end

@implementation ESSimulatedAnnealingMethodology

- (instancetype)initWithDataCache:(ESDataCache *)cache {
    if (self = [super init]) {
        self.cache = cache;
//        _initialTemperature = @(1200.95);
        _initialTemperature = @(0.95);
//        _freezingTemperature = @(pow(2, -10));
        _freezingTemperature = @(pow(2, -3));
        _phi = @(0.95);
        _perturb = @(0.1);
        _totalNumberOfSlots = @14;
    }
    return self;
}

- (void)prepareForSolve {
    NSParameterAssert(self.cache);
    self.bestSchedule = [ESSchedule randomScheduleWithTotalNumberOfSlots:self.totalNumberOfSlots cache:self.cache];
    self.currentTemperature = self.initialTemperature;
}

- (BOOL)shouldStopSolver {
    return [self.currentTemperature doubleValue] < [self.freezingTemperature doubleValue];
}

- (ESSchedule *)solveWithProgressBlock:(void(^)(CGFloat progress))progressBlock {
    [self prepareForSolve];

    NSParameterAssert(self.cache);

    NSInteger numberOfIterations = self.cache.courses.count * [self.totalNumberOfSlots integerValue];

    while (![self shouldStopSolver]) {
        ESSchedule *schedule = self.bestSchedule;
        for (NSInteger i = 0; i < numberOfIterations; i++) {
            @autoreleasepool {
                ESSchedule *perturbed = [schedule copy];
                perturbed.dataSource = self;
                NSInteger numberOfChangesToMake = arc4random() % (NSInteger)((self.cache.courses.count * [self.perturb doubleValue]) + 1);
                for (NSInteger i = 0; i < numberOfChangesToMake; i++) {
                    NSArray *courses = self.cache.courses;
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
                }
            }
        }
        self.currentTemperature = @([self.currentTemperature doubleValue] * [self.phi doubleValue]);
        if (progressBlock) {
            CGFloat normalized = ([self.currentTemperature doubleValue] - [self.initialTemperature doubleValue]) / ([self.freezingTemperature doubleValue] - [self.initialTemperature doubleValue]);
            progressBlock(normalized);
        }
    }
    
    return self.bestSchedule;
}

- (ESSchedule *)solve {
    return [self solveWithProgressBlock:nil];
}

- (void)solveWithProgress:(void(^)(CGFloat progress))progressBlock completionHandler:(void(^)(ESSchedule *bestSchedule))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ESSchedule *schedule = [self solveWithProgressBlock:^(CGFloat progress) {
            if (progressBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                });
            }
        }];
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
