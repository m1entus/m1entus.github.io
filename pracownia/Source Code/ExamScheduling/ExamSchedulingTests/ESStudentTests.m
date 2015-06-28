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
#import "ESDataCache.h"
#import "ESCourse.h"
#import <OCMock.h>


@interface ESStudentTests : XCTestCase
@property (nonatomic, strong) ESSchedule *schedule;
@end

@implementation ESStudentTests

static ESDataCache *_instanceOfDataCache = nil;

+ (void)setUp {
    [super setUp];

    _instanceOfDataCache = [[ESDataCache alloc] initWithLocalFileDataName:ESDataCacheStanfordDataPath];

    _instanceOfDataCache.mainBundle = [NSBundle bundleForClass:[self class]];
    [_instanceOfDataCache parseAndCacheData];
}

- (void)setUp {
    if (!self.schedule) {
        self.schedule = [[ESSchedule alloc] initWithTotalNumberOfSlots:@14 cache:_instanceOfDataCache];
        NSDictionary *dictionary = [ESCoursesFileParser parseSolutionSlotsFileAtPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"sta-f-83-stu-14slot" ofType:@"sol"]];
        [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
            ESCourse *course = [_instanceOfDataCache courseWithId:key];
            [self.schedule insertCourse:course toSlot:@([obj integerValue])];
        }];
    }
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSolution {

    NSString *stringQuality = [NSString stringWithFormat:@"%.6f",[self.schedule.quality doubleValue]];
    XCTAssertEqual([stringQuality doubleValue], 145.711948);
}

- (void)testStudentForOneSlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, 0);
    }];
}

- (void)testStudentForTwoSlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, ESSchedulePenaltyCounterConsecutiveExams[0]);
    }];

}

- (void)testStudentForNotOrderedSlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@3,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, 8+16+16);
    }];
}

- (void)testStudentForNotOrderedManySlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@4,@2,@3];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, 4+16+8+8+16+16);
    }];

}

- (void)testStudentForZeroNumberSlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@1,@0,@2];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];


    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, 16+16+8);
    }];
}

- (void)testStudentForZeroSlotInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@5,@0];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, 0);
        XCTAssertEqual(studentPenalty, 1);
    }];

}

- (void)testConflictAndStudentPenaltyInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@5,@0,@5];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, ESSchedulePenaltyCounterSimultaneousExams);
        XCTAssertEqual(studentPenalty, 2);
    }];
    
}

- (void)testConflictInSchedule {

    ESStudent *student = [[ESStudent alloc] init];

    id mockObject = [OCMockObject partialMockForObject:student];
    NSArray *slots = @[@5,@5];
    [[[mockObject stub] andReturn:@(slots.count)] myCoursesCount];
    [[[mockObject stub] andReturn:slots] myCoursesSlotsForSchedule:self.schedule];

    [student qualityOfSchedule:self.schedule withBlock:^(double simultaneousExamsPenalty, double studentPenalty) {
        XCTAssertEqual(simultaneousExamsPenalty, ESSchedulePenaltyCounterSimultaneousExams);
        XCTAssertEqual(studentPenalty, 0);
    }];
    
}

@end
