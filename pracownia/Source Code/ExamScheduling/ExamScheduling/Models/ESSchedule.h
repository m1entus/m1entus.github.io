//
//  ESSchedule.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>

@class ESCourse;

extern double const ESSchedulePenaltyCounterSimultaneousExams;
extern CGFloat const ESSchedulePenaltyCounterConsecutiveExams[5];

@interface ESSchedule : NSObject <NSCopying>
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, readonly, strong) NSMutableDictionary *slotForCourseId;

/**
 *  Quality of schedule based on student ranks
 */
@property (nonatomic, readonly) NSNumber *quality;

+ (instancetype)randomScheduleWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context;
- (instancetype)initWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context;

- (void)reassignCourse:(ESCourse *)course toSlot:(NSNumber *)slot;

- (NSNumber *)slotForCourse:(ESCourse *)course;
@end
