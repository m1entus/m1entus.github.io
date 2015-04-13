//
//  ExamSchedulingTests.m
//  ExamSchedulingTests
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <CoreData+MagicalRecord.h>
#import "ESCoursesFileParser.h"
#import "ESCourse.h"

@interface ExamSchedulingTests : XCTestCase

@end

@implementation ExamSchedulingTests

+ (void)setUp {
    [super setUp];

    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    [ESCoursesFileParser parseSynchronouslyFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"small5-stu" ofType:@"txt"] toContext:[NSManagedObjectContext MR_defaultContext]];
}

+ (void)tearDown {
    [MagicalRecord cleanUp];
    [super tearDown];
}

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


@end
