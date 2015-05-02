//
//  INSCell.h
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 06.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INSCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *topLine;

@property (nonatomic, strong) UIColor *color;

@end
