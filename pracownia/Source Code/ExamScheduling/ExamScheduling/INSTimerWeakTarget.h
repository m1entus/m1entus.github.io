//
//  INSTimerWeakTarget.h
//  INSElectronicProgramGuideLayout
//
//  Created by Michał Zaborowski on 01.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INSTimerWeakTarget : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, readonly) SEL fireSelector;

- (id)initWithTarget:(id)target selector:(SEL)selector;
@end
