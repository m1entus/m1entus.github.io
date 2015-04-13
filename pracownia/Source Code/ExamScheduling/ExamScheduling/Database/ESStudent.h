#import "_ESStudent.h"
#import "ESSchedule.h"

@interface ESStudent : _ESStudent {}
// Custom logic goes here.

+ (instancetype)studentWithId:(NSString *)studentId inContext:(NSManagedObjectContext *)context;

- (NSNumber *)qualityOfSchedule:(ESSchedule *)schedule;
@end
