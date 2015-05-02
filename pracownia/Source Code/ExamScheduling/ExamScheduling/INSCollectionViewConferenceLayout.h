//
//  INSCollectionViewConferenceLayout.h
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 05.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+INSUtils.h"

extern NSString *const INSConferenceLayoutElementKindSectionHeader;
extern NSString *const INSConferenceLayoutElementKindHourHeader;
extern NSString *const INSConferenceLayoutElementKindHalfHourHeader;

extern NSString *const INSConferenceLayoutElementKindSectionHeaderBackground;
extern NSString *const INSConferenceLayoutElementKindHourHeaderBackground;

extern NSString *const INSConferenceLayoutElementKindCurrentTimeIndicator;
extern NSString *const INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline;

extern NSString *const INSConferenceLayoutElementKindVerticalGridline;
extern NSString *const INSConferenceLayoutElementKindHalfHourVerticalGridline;
extern NSString *const INSConferenceLayoutElementKindHorizontalGridline;

extern NSString *const INSConferenceLayoutElementKindFloatingItemOverlay;
extern NSString *const INSConferenceLayoutElementKindFloatingDayHeader;

extern NSUInteger const INSConferenceLayoutMinOverlayZ;
extern NSUInteger const INSConferenceLayoutMinCellZ;
extern NSUInteger const INSConferenceLayoutMinBackgroundZ;

@protocol INSCollectionViewConferenceLayoutDataSource;
@protocol INSCollectionViewConferenceLayoutDelegate;

typedef NS_ENUM(NSUInteger, INSCollectionViewConferenceLayoutType) {
    INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn,
    INSCollectionViewConferenceLayoutTypeDayColumnAboveTimeRow
};

@interface INSCollectionViewConferenceLayout : UICollectionViewLayout
@property (nonatomic, assign) CGFloat sectionGap;
@property (nonatomic, assign) CGFloat sectionHeight;
@property (nonatomic, assign) CGFloat sectionHeaderWidth;

@property (nonatomic, assign) CGFloat daySectionGap;

@property (nonatomic, assign) CGSize currentTimeIndicatorSize;
@property (nonatomic, assign) CGFloat currentTimeVerticalGridlineWidth;

@property (nonatomic, assign) CGFloat horizontalGridlineHeight;
@property (nonatomic, assign) CGFloat verticalGridlineWidth;

@property (nonatomic, assign) CGFloat hourWidth;
@property (nonatomic, assign) CGFloat hourHeaderHeight;

@property (nonatomic, assign) CGSize floatingItemOverlaySize;
@property (nonatomic, assign) CGFloat floatingItemOffsetFromSection;

@property (nonatomic, assign) CGSize floatingDayHeaderSize;

@property (nonatomic, assign) UIEdgeInsets contentMargin;
@property (nonatomic, assign) UIEdgeInsets cellMargin;

@property (nonatomic, assign) INSCollectionViewConferenceLayoutType headerLayoutType;

@property (nonatomic, assign) BOOL shouldResizeStickyHeaders;

@property (nonatomic, assign) BOOL shouldUseFloatingItemOverlay;
@property (nonatomic, assign) BOOL shouldUseFloatingDayHeader;

@property (nonatomic, readonly) NSUInteger numberOfDays;

@property (nonatomic, weak) id <INSCollectionViewConferenceLayoutDataSource> dataSource;
@property (nonatomic, weak) id <INSCollectionViewConferenceLayoutDelegate> delegate;

- (NSDate *)dateForHourHeaderAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)dateForHalfHourHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (void)scrollToCurrentTimeAnimated:(BOOL)animated;

// Since a "reloadData" on the UICollectionView doesn't call "prepareForCollectionViewUpdates:", this method must be called first to flush the internal caches
- (void)invalidateLayoutCache;

- (NSDate *)startDateForDayAtIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)endDateForDayAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)minimumGridXForDayAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)maximumSectionWidthForDayAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)xCoordinateForDate:(NSDate *)date;

@end

@protocol INSCollectionViewConferenceLayoutDataSource <UICollectionViewDataSource>
@required
- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)currentTimeForCollectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)collectionViewLayout;

- (NSUInteger)numberOfDaysInCollectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)collectionViewLayout;

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout startTimeForDayAtIndexPath:(NSIndexPath *)indexPath;

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout endTimeForDayAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol INSCollectionViewConferenceLayoutDelegate <UICollectionViewDelegate>
@optional
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout sizeForFloatingItemOverlayAtIndexPath:(NSIndexPath *)indexPath;
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout sizeForFloatingDayHeaderAtSection:(NSUInteger)section;
@end
