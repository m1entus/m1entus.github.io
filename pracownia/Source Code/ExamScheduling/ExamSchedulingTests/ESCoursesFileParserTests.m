//
//  ESCoursesFileParserTests.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ESCoursesFileParser.h"
#import "ESCourse.h"


@interface ESCoursesFileParserTests : XCTestCase

@end

@implementation ESCoursesFileParserTests

- (void)testParsingData {
    [ESCoursesFileParser parseSynchronouslyFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"small5-stu" ofType:@"txt"] completionHandler:^(NSArray *students, NSArray *courses) {
        XCTAssertEqual(courses.count, 80);
    }];
}

- (void)testParsingSolution {

    NSDictionary *dictionary = [ESCoursesFileParser parseSolutionSlotsFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"14slotsSolution" ofType:@"txt"]];
    XCTAssertEqual(dictionary.allKeys.count, 139);
}

@end
