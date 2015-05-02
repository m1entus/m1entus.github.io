//
//  INSFloatingHeaderView.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 07.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSFloatingHeaderView.h"

@implementation INSFloatingHeaderView


- (void)awakeFromNib
{
    [super awakeFromNib];

    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)setDate:(NSDate *)day
{
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"EEEE";
    }
    self.dayNameLabel.text = [dateFormatter stringFromDate:day];
    [self setNeedsLayout];
}

@end
