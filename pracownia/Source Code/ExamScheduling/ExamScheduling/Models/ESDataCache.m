//
//  ESDatabaseDataCache.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import "ESDataCache.h"
#import "ESCoursesFileParser.h"
#import <FastCoder.h>

static NSString *const ESDataCacheDataPath = @"sta-f-83-stu";

@implementation ESDataCache

+ (NSString *)documentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

- (NSBundle *)mainBundle {
    if (!_mainBundle) {
        return [NSBundle mainBundle];
    }
    return _mainBundle;
}

+ (ESDataCache *)sharedInstance {
    static dispatch_once_t once;
    static ESDataCache *instanceOfDatabaseDataCache;
    dispatch_once(&once, ^ {
        NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:@"sta-f-83-stu.fast"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        instanceOfDatabaseDataCache = [FastCoder objectWithData:data];

        if (!instanceOfDatabaseDataCache) {
            instanceOfDatabaseDataCache = [[ESDataCache alloc] init];
            [instanceOfDatabaseDataCache parseAndCacheData];
        }
    });
    return instanceOfDatabaseDataCache;
}

- (void)parseAndCacheData {
    [ESCoursesFileParser parseSynchronouslyFileAtPath:[self.mainBundle pathForResource:ESDataCacheDataPath ofType:@"txt"] completionHandler:^(NSArray *students, NSArray *courses) {
        self.students = students;
        self.courses = courses;
        if (self.students.count && self.courses.count) {
            [self save];
        }
    }];
}

- (ESCourse *)courseWithId:(NSString *)courseId {
    for (ESCourse *course in self.courses) {
        if ([course.courseId isEqualToString:courseId]) {
            return course;
        }
    }
    return nil;
}

- (void)save {
    NSString *path = [[[self class] documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",ESDataCacheDataPath,@"fast"]];
    NSData *data = [FastCoder dataWithRootObject:self];
    [data writeToFile:path atomically:YES];
}
@end
