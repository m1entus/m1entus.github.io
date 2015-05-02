//
//  INSFloatingView.h
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 07.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface INSFloatingView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *leftLine;

@end
