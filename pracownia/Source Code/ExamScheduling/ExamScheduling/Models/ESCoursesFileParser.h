//
//  ESCoursesFileParser.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>

@interface ESCoursesFileParser : NSObject

+ (void)parseFileAtPath:(NSString *)path completionHandler:(void(^)(NSError *error))completionHandler;
+ (void)parseSynchronouslyFileAtPath:(NSString *)path toContext:(NSManagedObjectContext *)context;

+ (NSDictionary *)parseSolutionSlotsFileAtPath:(NSString *)path;
@end
