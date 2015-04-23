//
//  ESStudent.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 23.04.2015.
//
//

#import <Foundation/Foundation.h>

@class ESSchedule;

@interface ESStudent : NSObject
@property (nonatomic, strong) NSString *studentId;
@property (nonatomic, strong) NSArray *courses;

+ (instancetype)studentWithId:(NSString *)studentId courses:(NSArray *)courses;

- (void)qualityOfSchedule:(ESSchedule *)schedule withBlock:(void(^)(double simultaneousExamsPenalty, double studentPenalty))block;

- (NSArray *)myCoursesSlotsForSchedule:(ESSchedule *)schedule;
- (NSInteger)myCoursesCount;
@end
