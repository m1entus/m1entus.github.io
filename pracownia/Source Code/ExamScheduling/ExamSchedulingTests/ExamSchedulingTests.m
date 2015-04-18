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
#import "ESSchedule.h"
#import "ESSimulatedAnnealing.h"

#define ARC4RANDOM_MAX      0x100000000

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

- (void)testScheduleGeneration {
//    [ESSchedule randomScheduleWithTotalNumberOfSlots:@14 inContext:[NSManagedObjectContext MR_defaultContext]];

    ESSimulatedAnnealing *sa = [[ESSimulatedAnnealing alloc] initWithContext:[NSManagedObjectContext MR_defaultContext]];
    ESSchedule *schedule = [sa solve];

    schedule;
//    for (int i = 0; i < 1000; i++) {
//        NSInteger numberOfChangesToMake = (NSInteger)(((double)arc4random() / ARC4RANDOM_MAX) * 60 * [@0.1 doubleValue]) + 1;
//        double numberOfChangesToMake = (double)(arc4random() % ((unsigned)RAND_MAX + 1)) / (double)RAND_MAX;
//        NSLog(@"%f",numberOfChangesToMake);
//    }

}


@end