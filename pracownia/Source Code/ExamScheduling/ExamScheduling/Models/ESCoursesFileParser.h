//
//  ESCoursesFileParser.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>

typedef void(^ESCoursesFileParserCompletionHandler)(NSArray *students, NSArray *courses);

@interface ESCoursesFileParser : NSObject

+ (void)parseFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler;
+ (void)parseSynchronouslyFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler;

+ (NSDictionary *)parseSolutionSlotsFileAtPath:(NSString *)path;
@end
