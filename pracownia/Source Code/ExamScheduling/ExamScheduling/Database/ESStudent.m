#import "ESStudent.h"
#import "ESSchedule.h"
#import "ESDatabaseDataCache.h"

@interface ESStudent ()

// Private interface goes here.

@end

@implementation ESStudent

- (NSInteger)myCoursesCount {
    return self.courses.count;
}

- (NSArray *)myCoursesSlotsForSchedule:(ESSchedule *)schedule {
    NSMutableArray *myCoursesSlots = [NSMutableArray arrayWithCapacity:[self myCoursesCount]];

    for (ESCourse *course in self.courses) {
        [myCoursesSlots addObject:[schedule slotForCourse:course]];
    }
    return [myCoursesSlots copy];
}

- (void)qualityOfSchedule:(ESSchedule *)schedule withBlock:(void(^)(double simultaneousExamsPenalty, double studentPenalty))block {

    double simultaneousExamsPenalty = 0.0;
    double studentPenalty = 0.0;

    NSArray *myCoursesSlots = [self myCoursesSlotsForSchedule:schedule];

    if (myCoursesSlots.count > 1) {

        for (NSInteger i = 0; i < myCoursesSlots.count - 1; i++) {

            for (NSInteger j = i+1; j < myCoursesSlots.count; j++) {
                NSNumber *slot1 = myCoursesSlots[i];
                NSNumber *slot2 = myCoursesSlots[j];
                NSInteger slot1Integer = [slot1 integerValue];
                NSInteger slot2Integer = [slot2 integerValue];

                // detect conflict
                if (slot1Integer == slot2Integer) {
                    simultaneousExamsPenalty += ESSchedulePenaltyCounterSimultaneousExams;
                } else {
                    NSInteger penaltiesLevel = sizeof(ESSchedulePenaltyCounterConsecutiveExams) / sizeof(*ESSchedulePenaltyCounterConsecutiveExams);
                    NSInteger penalty = abs((int)slot2Integer - (int)slot1Integer) - 1;
                    if (penalty < penaltiesLevel && penalty >= 0) {
                        studentPenalty += ESSchedulePenaltyCounterConsecutiveExams[penalty];
                    }
                }
            }
        }
    }

    if (block) {
        block(simultaneousExamsPenalty,studentPenalty);
    }

}


+ (instancetype)studentWithId:(NSString *)studentId inContext:(NSManagedObjectContext *)context {

    ESStudent *student = [ESStudent MR_findFirstByAttribute:@"studentId" withValue:studentId inContext:context];
    if (!student) {
        student = [ESStudent MR_createInContext:context];
        student.studentId = [studentId copy];
    }
    return student;
}

@end
