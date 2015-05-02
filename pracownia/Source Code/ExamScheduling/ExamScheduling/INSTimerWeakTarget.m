//
//  INSTimerWeakTarget.m
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 01.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSTimerWeakTarget.h"

@implementation INSTimerWeakTarget

- (id)initWithTarget:(id)target selector:(SEL)selector
{
    self = [super init];
    if (self) {
        self.target = target;
        self.selector = selector;
    }
    return self;
}

- (void)fire:(NSTimer *)timer
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.target performSelector:self.selector withObject:timer];
#pragma clang diagnostic pop
}

- (SEL)fireSelector
{
    return @selector(fire:);
}

@end
