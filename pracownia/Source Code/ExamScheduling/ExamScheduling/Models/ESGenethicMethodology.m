//
//  ESPopulation.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import "ESGenethicMethodology.h"
#import "ESDatabaseDataCache.h"
#import "NSNumber+Random.h"

@interface ESGenethicMethodology ()
@property (nonatomic, readwrite, strong) ESSchedule *bestSchedule;
@property (nonatomic, strong) NSMutableOrderedSet *populationPool;
@end

@implementation ESGenethicMethodology

- (instancetype)initWithPopulationSize:(NSInteger)size context:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _totalNumberOfSlots = @15;
        _crossoverRate = @0.75;
        _mutationRate = @0.25;
        _topbreedRate = @0.2;
        _freshBloodRate = @0.1;
        _numberOfGenerations = @500;
        _populationSize = size;
        _context = context;
    }
    return self;
}

- (void)prepareForSolve {
    self.populationPool = [[NSMutableOrderedSet alloc] initWithCapacity:self.populationSize];

    for (NSInteger i = 0; i < self.populationSize; i++) {
        [self.populationPool addObject:[ESSchedule randomScheduleWithTotalNumberOfSlots:self.totalNumberOfSlots inContext:self.context]];
    }
}

- (ESSchedule *)solve {
    [self prepareForSolve];

    for (NSInteger i = 0; i < [self.numberOfGenerations integerValue]; i++) {
        @autoreleasepool {
            [self nextGeneration];
        }
    }
    return self.bestSchedule;
}

- (void)nextGeneration {
    self.bestSchedule = [self.populationPool firstObject];
    NSInteger wheelCapacity = (NSInteger) (self.populationPool.count * [self.crossoverRate doubleValue]);
    NSMutableArray *wheel = [NSMutableArray arrayWithCapacity:wheelCapacity];
    for (NSInteger i = 0; i < wheelCapacity; i++) {
        [wheel addObject:[NSNull null]];
    }

    NSNumber *topQuality = [[self.populationPool firstObject] quality];

    NSEnumerator *poolEnumerator = self.populationPool.objectEnumerator;
    for (NSInteger i = 0; i < wheel.count; i++) {
        ESSchedule *schedule = [poolEnumerator nextObject];
        if (!schedule) {
            break;
        }
        if (i < (self.populationPool.count * [self.topbreedRate doubleValue])) {
            wheel[i] = schedule;
        } else {
            double probabilty = [topQuality doubleValue] /  [schedule.quality doubleValue];
            double randomDouble = [[NSNumber randomDouble] doubleValue];
            if (randomDouble < probabilty) {
                wheel[i] = schedule;
            }
        }
    }

    for (NSInteger i = 0; i < wheel.count/2; i++) {
        ESSchedule *firstSchedule = wheel[ arc4random() % (wheel.count-1) ];
        ESSchedule *secondSchedule = wheel[ arc4random() % (wheel.count-1) ];
        if (firstSchedule && secondSchedule && ![firstSchedule isKindOfClass:[NSNull class]] && ![secondSchedule isKindOfClass:[NSNull class]]) {
            NSArray *children = [self crossoverWithFirstParent:firstSchedule secondParent:secondSchedule];
            for (ESSchedule *child in children) {
                if ([[[self.populationPool lastObject] quality] doubleValue] > [child.quality doubleValue]) {
                    [self.populationPool removeObject:[self.populationPool lastObject]];
                    [self.populationPool addObject:child];
                }
            }
        }
    }

    for (NSInteger i = 0; i < (NSInteger)(self.populationPool.count * [self.freshBloodRate doubleValue]); i++) {
        [self.populationPool removeObject:[self.populationPool lastObject]];
    }

    while (self.populationPool.count < self.populationSize) {
        [self.populationPool addObject:[ESSchedule randomScheduleWithTotalNumberOfSlots:self.totalNumberOfSlots inContext:self.context]];
    }
}

- (NSArray *)crossoverWithFirstParent:(ESSchedule *)firstParent secondParent:(ESSchedule *)secondParent {
    NSMutableArray *children = [NSMutableArray arrayWithCapacity:2];
    ESSchedule *firstChild  = [firstParent copy];
    ESSchedule *secondChild = [secondParent copy];

    NSInteger k = arc4random() % ([ESDatabaseDataCache sharedInstance].courses.count - 1) + 1;
    for (NSInteger i = arc4random() % k; i < k; i++) {
        ESCourse *course  = [ESDatabaseDataCache sharedInstance].courses[i];
        NSNumber *newSlotLocation = [firstChild slotForCourse:course];
        [firstChild reassignCourse:course toSlot:[secondChild slotForCourse:course]];
        [secondChild reassignCourse:course toSlot:newSlotLocation];
    }

    if ([[NSNumber randomDouble] doubleValue] < [self.mutationRate doubleValue]) {
        [self mutateChild:firstChild];
    }

    if ([[NSNumber randomDouble] doubleValue] < [self.mutationRate doubleValue]) {
        [self mutateChild:secondChild];
    }

    [firstChild quality];
    [secondChild quality];

    [children addObject:firstChild];
    [children addObject:secondChild];

    return [children copy];
}

- (void)mutateChild:(ESSchedule *)child {
    ESCourse *course = [ESDatabaseDataCache sharedInstance].courses[ arc4random() % ([ESDatabaseDataCache sharedInstance].courses.count - 1)];
    [child reassignCourse:course toSlot:@(arc4random() % [ESDatabaseDataCache sharedInstance].courses.count)];
}

@end
