//
//  ESCourse.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 23.04.2015.
//
//

#import "ESCourse.h"

@implementation ESCourse

+ (NSArray *)coursesFromIDs:(NSArray *)courseIds {
    NSMutableArray *courses = [NSMutableArray arrayWithCapacity:courseIds.count];

    for (NSString *courseId in courseIds) {
        ESCourse *course = [[ESCourse alloc] init];
        course.courseId = courseId;
        [courses addObject:course];
    }
    return [courses copy];
}
@end
