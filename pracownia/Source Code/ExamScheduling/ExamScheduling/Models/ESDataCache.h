//
//  ESDatabaseDataCache.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import <Foundation/Foundation.h>
#import "ESCourse.h"

@class ESSchedule;

extern NSString *const ESDataCacheTestDataPath;
extern NSString *const ESDataCacheStanfordDataPath;

@interface ESDataCache : NSObject
@property (nonatomic, strong) NSArray *students;
@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, strong) NSBundle *mainBundle;

@property (nonatomic, strong) ESSchedule *bestSchedule;

- (instancetype)initWithLocalFileDataName:(NSString *)localFileName;

- (void)parseAndCacheData;

- (ESCourse *)courseWithId:(NSString *)courseId;

- (void)save;
@end
