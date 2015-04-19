//
//  ESDatabaseDataCache.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import "ESDatabaseDataCache.h"
#import "ESCourse.h"
#import "ESStudent.h"

@implementation ESDatabaseDataCache

+ (ESDatabaseDataCache *)sharedInstance {
    static dispatch_once_t once;
    static ESDatabaseDataCache *instanceOfDatabaseDataCache;
    dispatch_once(&once, ^ { instanceOfDatabaseDataCache = [[ESDatabaseDataCache alloc] init]; });
    return instanceOfDatabaseDataCache;
}

- (void)cacheForContext:(NSManagedObjectContext *)context {
    self.courses = [ESCourse MR_findAllSortedBy:@"courseId" ascending:YES inContext:context];
    self.students = [ESStudent MR_findAllInContext:context];
}

@end
