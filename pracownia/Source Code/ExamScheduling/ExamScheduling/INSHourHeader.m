//
//  INSHourHeader.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 06.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSHourHeader.h"

@interface INSHourHeader ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation INSHourHeader

+ (NSDateFormatter *)sharedTimeRowHeaderDateFormatter
{
    static dispatch_once_t once;
    static NSDateFormatter *_sharedTimeRowHeaderDateFormatter;
    dispatch_once(&once, ^ { _sharedTimeRowHeaderDateFormatter = [[NSDateFormatter alloc] init];
        _sharedTimeRowHeaderDateFormatter.dateFormat = @"HH";
    });
    return _sharedTimeRowHeaderDateFormatter;
}

- (void)setTime:(NSDate *)time
{
    _time = time;

    self.timeLabel.text = [NSString stringWithFormat:@"Slot: %@",@([[[[self class] sharedTimeRowHeaderDateFormatter] stringFromDate:time] integerValue]+1)];

    [self setNeedsLayout];
}

@end
