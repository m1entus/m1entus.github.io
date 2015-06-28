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

+ (void)parseSynchronouslyFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler {

    NSString *fileContents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [self parseContentOfString:fileContents completionHandler:completionHandler];
}

+ (void)parseContentOfString:(NSString *)fileContents completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler {

    NSMutableArray *values = [[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];

    [values removeObject:@""];

    NSMutableArray *students = [NSMutableArray arrayWithCapacity:values.count];
    NSMutableDictionary *coursesDictionary = [NSMutableDictionary dictionary];

    for (NSUInteger i = 0; i < values.count; i++) {
        NSString *line = values[i];
        NSString *studentId = [NSString stringWithFormat:@"%lu",(unsigned long)i];
        NSMutableArray *coursesIdsForStudent = [[line componentsSeparatedByString:@" "] mutableCopy];
        [coursesIdsForStudent removeObject:@""];
        [coursesIdsForStudent removeObject:@" "];


        NSArray *courses = [ESCourse coursesFromIDs:coursesIdsForStudent];
        ESStudent *student = [ESStudent studentWithId:studentId courses:courses];
        [students addObject:student];

        for (ESCourse *course in courses) {
            if (!coursesDictionary[course.courseId]) {
                coursesDictionary[course.courseId] = course;
            }
        }
    }

    if (completionHandler) {
        completionHandler([students copy],[coursesDictionary allValues]);
    }
}

+ (void)parseSynchronouslyFileAtURL:(NSURL *)URL completionHandler:(ESCoursesURLParserCompletionHandler)completionHandler {
    NSData *data = [NSData dataWithContentsOfURL:URL];
    NSString *stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (stringData.length > 0) {
        [self parseContentOfString:stringData completionHandler:^(NSArray *students, NSArray *courses) {
            if (students.count > 0 && courses.count > 0) {
                if (completionHandler) {
                    completionHandler(students,courses,nil);
                }
            } else {
                if (completionHandler) {
                    completionHandler(nil,nil,[NSError errorWithDomain:@"ESCoursesFileParsesDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Wrong file or URL"}]);
                }
            }
        }];
    } else {
        if (completionHandler) {
            completionHandler(nil,nil,[NSError errorWithDomain:@"ESCoursesFileParsesDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Wrong file or URL"}]);
        }
    }


}

+ (void)parseFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self parseFileAtPath:path completionHandler:^(NSArray *students, NSArray *courses) {
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(students,courses);
                });
            }
        }];
    });
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
