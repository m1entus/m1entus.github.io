//
//  INSSectionBackgroundView.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 09.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSSectionBackgroundView.h"

@implementation INSSectionBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [UIColor whiteColor];

        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width-1, 0, 1, self.bounds.size.height)];
        subView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        subView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:subView];
    }
    return self;
}

@end
