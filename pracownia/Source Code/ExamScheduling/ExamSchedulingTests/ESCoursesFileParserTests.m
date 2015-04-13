//
//  ESCoursesFileParserTests.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData+MagicalRecord.h>
#import "ESCoursesFileParser.h"
#import "ESCourse.h"


@interface ESCoursesFileParserTests : XCTestCase

@end

@implementation ESCoursesFileParserTests

- (void)setUp {
    [super setUp];

    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown {
    [MagicalRecord cleanUp];
    [super tearDown];
}
- (void)testParsing {
    XCTAssertEqual([ESCourse MR_countOfEntities], 0);

    [ESCoursesFileParser parseSynchronouslyFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"small5-stu" ofType:@"txt"] toContext:[NSManagedObjectContext MR_defaultContext]];

    XCTAssertEqual([ESCourse MR_countOfEntities], 80);
}

@end
