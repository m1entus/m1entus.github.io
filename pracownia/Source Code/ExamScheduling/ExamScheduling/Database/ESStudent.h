#import "_ESStudent.h"
#import "ESSchedule.h"
#import "ESCourse.h"

@interface ESStudent : _ESStudent {}
// Custom logic goes here.

+ (instancetype)studentWithId:(NSString *)studentId inContext:(NSManagedObjectContext *)context;

- (void)qualityOfSchedule:(ESSchedule *)schedule withBlock:(void(^)(double simultaneousExamsPenalty, double studentPenalty))block;

- (NSArray *)myCoursesSlotsForSchedule:(ESSchedule *)schedule;
- (NSInteger)myCoursesCount;

@end
