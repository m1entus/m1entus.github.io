//
//  INSFloatingHeaderView.h
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 07.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INSFloatingHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *dayNameLabel;

- (void)setDate:(NSDate *)date;
@end
