//
//  ESSchedule.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>

@interface ESSchedule : NSObject
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly) NSNumber *quality;

+ (instancetype)scheduleWithTotalNumberOfSlots:(NSNumber *)numberOfSlots inContext:(NSManagedObjectContext *)context;
@end
