//
//  ESDatabaseDataCache.h
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import <Foundation/Foundation.h>

@interface ESDatabaseDataCache : NSObject
@property (nonatomic, strong) NSArray *students;
@property (nonatomic, strong) NSArray *courses;

+ (ESDatabaseDataCache *)sharedInstance;
- (void)cacheForContext:(NSManagedObjectContext *)context;
@end
