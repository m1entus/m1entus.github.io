//
//  NSNumber+Random.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 19.04.2015.
//
//

#import "NSNumber+Random.h"

@implementation NSNumber (Random)

+ (instancetype)randomDouble {
    return @((double)(arc4random() % ((unsigned)RAND_MAX + 1)) / (double)RAND_MAX);
}

@end
