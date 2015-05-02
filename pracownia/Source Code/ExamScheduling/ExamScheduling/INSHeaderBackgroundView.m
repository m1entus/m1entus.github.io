//
//  INSHeaderBackgroundView.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 07.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSHeaderBackgroundView.h"

@implementation INSHeaderBackgroundView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [UIColor whiteColor];

        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        subView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        subView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:subView];
    }
    return self;
}

@end
