//
//  ESCoursesFileParser.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <Foundation/Foundation.h>

typedef void(^ESCoursesFileParserCompletionHandler)(NSArray *students, NSArray *courses);
typedef void(^ESCoursesURLParserCompletionHandler)(NSArray *students, NSArray *courses, NSError *error);

@interface ESCoursesFileParser : NSObject

+ (void)parseFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler;
+ (void)parseSynchronouslyFileAtPath:(NSString *)path completionHandler:(ESCoursesFileParserCompletionHandler)completionHandler;
+ (void)parseSynchronouslyFileAtURL:(NSURL *)URL completionHandler:(ESCoursesURLParserCompletionHandler)completionHandler;

+ (NSDictionary *)parseSolutionSlotsFileAtPath:(NSString *)path;
@end
