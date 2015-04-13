//
//  RESimulatedAnnealing.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSimulatedAnnealing.h"

@interface ESSimulatedAnnealing ()
@property (nonatomic, readwrite, strong) ESSchedule *bestSchedule;
@end

@implementation ESSimulatedAnnealing

+ (instancetype)solverForContext:(NSManagedObjectContext *)context {
    return [[self alloc] initWithContext:context];
}

- (instancetype)initWithContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _initialTemperature = @(0.93);
        _freezingTemperature = @(pow(2, -30));
        _phi = @(0.95);
        _perturb = @(0.1);
        _totalNumberOfSlots = @14;
    }
    return self;
}



@end
