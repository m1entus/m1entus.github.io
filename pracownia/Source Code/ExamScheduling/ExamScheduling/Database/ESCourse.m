#import "ESCourse.h"
#import "ESStudent.h"
#import "ESDatabaseDataCache.h"

@interface ESCourse ()

// Private interface goes here.

@end

@implementation ESCourse

+ (NSArray *)coursesFromIds:(NSArray *)coursesIds inContext:(NSManagedObjectContext *)context {

    NSMutableArray *courses = [NSMutableArray arrayWithCapacity:coursesIds.count];

    for (NSString *courseId in coursesIds) {
        [courses addObject:[ESCourse courseWithId:courseId inContext:context]];
    }
    return [courses copy];
}

+ (ESCourse *)courseWithId:(NSString *)courseId inContext:(NSManagedObjectContext *)context {
    ESCourse *course = [ESCourse MR_findFirstByAttribute:@"courseId" withValue:courseId inContext:context];
    if (!course) {
        course = [ESCourse MR_createInContext:context];
        course.courseId = [courseId copy];
    }
    return course;
}

@end
