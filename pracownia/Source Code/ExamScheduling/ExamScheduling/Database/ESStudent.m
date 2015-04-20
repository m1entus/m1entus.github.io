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
        for (NSInteger j = i+1; j < myCourses.count; j++) {
            // detect conflict
            if ([myCoursesSlots[i] integerValue] == [myCoursesSlots[j] integerValue]) {
                quality += ESSchedulePenaltyCounterSimultaneousExams;
            }
        }
    }


    if (myCoursesSlots.count > 1) {
        NSArray *sortedSlots = [myCoursesSlots sortedArrayUsingComparator:^NSComparisonResult(NSNumber *slot1, NSNumber *slot2) {
            return [slot1 compare:slot2];
        }];

        for (NSInteger i = 0; i < sortedSlots.count - 1; i++) {
            NSNumber *slot1 = sortedSlots[i];
            NSNumber *slot2 = sortedSlots[i+1];

            NSInteger penaltiesLevel = sizeof(ESSchedulePenaltyCounterConsecutiveExams) / sizeof(*ESSchedulePenaltyCounterConsecutiveExams);
            NSInteger penalty = abs([slot1 integerValue] - [slot2 integerValue]) - 1;

            if (penalty < penaltiesLevel) {
                quality += ESSchedulePenaltyCounterConsecutiveExams[penalty];
            }

        }
    }

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
