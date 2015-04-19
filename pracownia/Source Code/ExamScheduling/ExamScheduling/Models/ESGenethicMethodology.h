//
//  ESPopulation.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "ESSchedule.h"

@interface ESGenethicMethodology : NSObject
@property (nonatomic, readonly) ESSchedule *bestSchedule;

@property (nonatomic, assign) NSInteger populationSize;
@property (nonatomic, assign) NSNumber *numberOfGenerations;

@property (nonatomic, strong) NSNumber *crossoverRate;
@property (nonatomic, strong) NSNumber *mutationRate;
@property (nonatomic, strong) NSNumber *topbreedRate;
@property (nonatomic, strong) NSNumber *freshBloodRate;

/*
 * Total number of slots, default to 14
 */
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;

@property (nonatomic, strong) NSManagedObjectContext *context;

- (instancetype)initWithPopulationSize:(NSInteger)size context:(NSManagedObjectContext *)context;

- (ESSchedule *)solve;
@end
