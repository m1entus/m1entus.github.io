#import "ESStudent.h"

@interface ESStudent ()

// Private interface goes here.

@end

@implementation ESStudent

- (NSNumber *)qualityOfSchedule:(ESSchedule *)schedule {
    return nil;
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
