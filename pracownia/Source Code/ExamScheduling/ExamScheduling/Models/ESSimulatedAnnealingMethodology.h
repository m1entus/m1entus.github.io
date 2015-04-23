//
//  RESimulatedAnnealing.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "ESSchedule.h"

@interface ESSimulatedAnnealingMethodology : NSObject

/*
 * Initial Temperature, default to 0.93
 */
@property (nonatomic, strong) NSNumber *initialTemperature;

/*
 * Freezing Temperature, default to 2^-30
 */
@property (nonatomic, strong) NSNumber *freezingTemperature;

/*
 * Temperature decreasing rate, T1=T0*PHI, default to 0.95, range (0, 1)
 */
@property (nonatomic, strong) NSNumber *phi;

/*
 * Perturb rate, default to 0.1
 */
@property (nonatomic, strong) NSNumber *perturb;

/*
 * Total number of slots, default to 14
 */
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

@property (nonatomic, readonly) ESSchedule *bestSchedule;

- (instancetype)init;

- (ESSchedule *)solve;

- (void)solveWithCompletionHandler:(void(^)(ESSchedule *bestSchedule))completion;

@end
