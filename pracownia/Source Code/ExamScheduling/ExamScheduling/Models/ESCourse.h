//
//  ESCourse.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 23.04.2015.
//
//

#import <Foundation/Foundation.h>

@interface ESCourse : NSObject
@property (nonatomic, strong) NSString *courseId;

+ (NSArray *)coursesFromIDs:(NSArray *)courseIds;
@end
