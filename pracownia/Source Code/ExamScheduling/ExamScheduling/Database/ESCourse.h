#import "_ESCourse.h"
#import "ESSchedule.h"

@interface ESCourse : _ESCourse {}
// Custom logic goes here.

+ (NSArray *)coursesFromIds:(NSArray *)coursesIds inContext:(NSManagedObjectContext *)context;
@end
