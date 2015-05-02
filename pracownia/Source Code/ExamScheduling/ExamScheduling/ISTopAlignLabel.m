//
//  ISTopAlignTabel.m
//  iLumio Guest
//
//  Created by Michał Zaborowski on 21.09.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "ISTopAlignLabel.h"

@implementation ISTopAlignLabel

- (void)drawTextInRect:(CGRect)rect
{
    CGRect labelStringRect = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 9999)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:self.font}
                                                     context:nil];

    [super drawTextInRect:CGRectMake(0, 0, self.frame.size.width, labelStringRect.size.height > rect.size.height ? rect.size.height : labelStringRect.size.height)];
    
    
}
@end
