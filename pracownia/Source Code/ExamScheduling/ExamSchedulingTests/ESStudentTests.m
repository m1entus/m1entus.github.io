//
//  ESStudentTests.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 21.04.2015.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ESCoursesFileParser.h"
#import "ESStudent.h"
#import "ESSchedule.h"
#import "ESDatabaseDataCache.h"
#import "ESCourse.h"
#import <OCMock.h>


@interface ESStudentTests : XCTestCase
@property (nonatomic, strong) ESSchedule *schedule;
@end

@implementation ESStudentTests

+ (void)setUp {
    [super setUp];

    [MagicalRecord setDefaultModelFromClass:[self class]];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    [ESCoursesFileParser parseSynchronouslyFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"sta-f-83-stu" ofType:@"txt"] toContext:[NSManagedObjectContext MR_defaultContext]];
    [[ESDatabaseDataCache sharedInstance] cacheForContext:[NSManagedObjectContext MR_defaultContext]];
}

- (void)setUp {
    if (!self.schedule) {
        self.schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:@14 inContext:[NSManagedObjectContext MR_defaultContext]];
        NSDictionary *dictionary = [ESCoursesFileParser parseSolutionSlotsFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"sta-f-83-stu-14slot" ofType:@"sol"]];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            ESCourse *course = [ESCourse MR_findFirstByAttribute:@"courseId" withValue:key];
            [self.schedule insertCourse:course toSlot:@([obj integerValue])];
        }];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testSolution {

    NSString *stringQuality = [NSString stringWithFormat:@"%.6f",[self.schedule.quality doubleValue]];
    XCTAssertEqual([stringQuality doubleValue], 147.420622);
}

- (void)testStudentForOneSlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, 0);
    }];
}

- (void)testStudentForTwoSlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, ESSchedulePenaltyCounterConsecutiveExams[0]);
    }];

}

- (void)testStudentForNotOrderedSlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@3,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, 8+16+16);
    }];
}

- (void)testStudentForNotOrderedManySlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@4,@2,@3];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, 4+16+8+8+16+16);
    }];

}

- (void)testStudentForZeroNumberSlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@0,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];


    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, 16+16+8);
    }];
}

- (void)testStudentForZeroSlotInSchedule {

    ESStudent *student = [ESStudent MR_createInContext:[NSManagedObjectContext MR_defaultContext]];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@5,@0];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(studentPenalty, 1);
    }];

}

@end
