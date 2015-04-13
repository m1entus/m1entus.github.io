#import "_ESCourse.h"

@interface ESCourse : _ESCourse {}
// Custom logic goes here.

+ (NSArray *)coursesFromIds:(NSArray *)coursesIds inContext:(NSManagedObjectContext *)context;
@end
