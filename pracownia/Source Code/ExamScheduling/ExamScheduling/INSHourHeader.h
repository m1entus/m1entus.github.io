//
//  INSHourHeader.h
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 06.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INSHourHeader : UICollectionReusableView
@property (nonatomic, strong) NSDate *time;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightSideConstraint;
@end
