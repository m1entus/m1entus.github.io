//
//  INSCell.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 06.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSCell.h"
#import "UIColor+LightAndDark.h"

@implementation INSCell

- (void)setColor:(UIColor *)color
{
    _color = color;
    self.topLine.backgroundColor = color;
    self.backgroundColor = [[[[color lighterColor] lighterColor] lighterColor] colorWithAlphaComponent:0.5];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

@end
