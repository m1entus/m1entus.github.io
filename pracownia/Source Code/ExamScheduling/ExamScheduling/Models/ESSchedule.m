//
//  ESSchedule.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESSchedule.h"

@interface ESSchedule ()
@property (nonatomic, strong, readwrite) NSNumber *quality;
@property (nonatomic, strong) NSNumber *totalNumberOfSlots;
@end

@implementation ESSchedule

- (NSNumber *)quality {
    if (!_quality) {
        // calculate rank
        
    }
    return _quality;
}

+ (instancetype)scheduleWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context {
    return [[self alloc] initWithTotalNumberOfSlots:numberOfSlots inContext:context];
}

- (instancetype)initWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context {
    if (self = [super init]) {
        _totalNumberOfSlots = numberOfSlots;
        _context = context;
    }
    return self;
}

@end
