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
#import "ESSchedule.h"

NSString *const ESDataCacheTestDataPath = @"small5-stu";
NSString *const ESDataCacheStanfordDataPath = @"sta-f-83-stu";

@interface ESDataCache ()
@property (nonatomic, strong) NSString *localFileName;
@end

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

- (instancetype)initWithLocalFileDataName:(NSString *)localFileName {
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.fast",localFileName] ofType:nil];

    NSData *data = [NSData dataWithContentsOfFile:path];
    ESDataCache *cache = [FastCoder objectWithData:data];

    if (cache) {
        self = cache;
    } else {
        if (self = [super init]) {
            self.localFileName = localFileName;
            [self parseAndCacheData];
        }
    }

    return self;
}

- (void)parseAndCacheData {
    [ESCoursesFileParser parseSynchronouslyFileAtPath:[self.mainBundle pathForResource:self.localFileName ofType:@"txt"] completionHandler:^(NSArray *students, NSArray *courses) {
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
    if (self.localFileName) {
        NSString *path = [[[self class] documentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",self.localFileName,@"fast"]];
        NSData *data = [FastCoder dataWithRootObject:self];
        [data writeToFile:path atomically:YES];
    }

}
@end
