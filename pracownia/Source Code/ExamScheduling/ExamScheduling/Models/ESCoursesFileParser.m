//
//  ESCoursesFileParser.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ESCoursesFileParser.h"
#import "ESStudent.h"
#import "ESCourse.h"

@implementation ESCoursesFileParser

+ (void)parseSynchronouslyFileAtPath:(NSString *)path toContext:(NSManagedObjectContext *)localContext {
    [ESCourse MR_truncateAllInContext:localContext];
    [ESStudent MR_truncateAllInContext:localContext];

    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSMutableArray *values = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
    
    [values removeObject:@""];


    for (NSUInteger i = 0; i < values.count; i++) {
        NSString *line = values[i];
        NSString *studentId = [NSString stringWithFormat:@"%lu",(unsigned long)i];
        NSMutableArray *coursesIdsForStudent = [[line componentsSeparatedByString:@" "] mutableCopy];
        [coursesIdsForStudent removeObject:@""];
        [coursesIdsForStudent removeObject:@" "];

        ESStudent *student = [ESStudent studentWithId:studentId inContext:localContext];
        NSArray *courses = [ESCourse coursesFromIds:coursesIdsForStudent inContext:localContext];
        [student addCourses:[NSSet setWithArray:courses]];

    }
}

+ (void)parseFileAtPath:(NSString *)path completionHandler:(void(^)(NSError *error))completionHandler {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        [self parseSynchronouslyFileAtPath:path toContext:localContext];

    } completion:^(BOOL success, NSError *error) {
        if (completionHandler) {
            completionHandler(error);
        }
    }];
}

+ (NSDictionary *)parseSolutionSlotsFileAtPath:(NSString *)path {
    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    NSMutableArray *values = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];

    [values removeObject:@""];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    for (NSUInteger i = 0; i < values.count; i++) {
        NSString *line = [[values[i] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@";" withString:@""];
        NSMutableArray *coursesIdsForSlot = [[line componentsSeparatedByString:@"="] mutableCopy];
        dictionary[[coursesIdsForSlot firstObject]] = [coursesIdsForSlot lastObject];
    }
    return [dictionary copy];
}

@end
