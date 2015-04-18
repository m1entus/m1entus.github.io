#import "ESStudent.h"
#import "ESSchedule.h"

@interface ESStudent ()

// Private interface goes here.

@end

@implementation ESStudent

- (NSNumber *)qualityOfSchedule:(ESSchedule *)schedule {

    double quality = 0.0;

    NSArray *myCourses = [self.courses allObjects];
    NSMutableArray *myCoursesSlots = [NSMutableArray arrayWithCapacity:myCourses.count];

    for (ESCourse *course in myCourses) {
        [myCoursesSlots addObject:[schedule slotForCourse:course]];
    }

    for (NSInteger i = 0; i < myCourses.count-1; i++) {
        for (NSInteger j = myCourses.count-1; j < myCourses.count; j++) {
            // detect conflict
            if ([myCoursesSlots[i] integerValue] == [myCoursesSlots[j] integerValue]) {
                quality += ESSchedulePenaltyCounterSimultaneousExams;
            }

            if (abs([myCoursesSlots[i] integerValue] - [myCoursesSlots[j] integerValue]) == 1) {
                quality += ESSchedulePenaltyCounterConsecutiveExams;
            }
        }
    }

    // detect more than two exam per day

    return @(quality);
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
