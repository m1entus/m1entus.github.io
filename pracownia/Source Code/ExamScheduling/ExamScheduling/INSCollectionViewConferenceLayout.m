//
//  INSCollectionViewConferenceLayout.m
//  INSCollectionViewConferenceLayout
//
//  Created by Michał Zaborowski on 05.10.2014.
//  Copyright (c) 2014 inspace.io. All rights reserved.
//

#import "INSCollectionViewConferenceLayout.h"
#import "INSTimerWeakTarget.h"

NSString *const INSConferenceLayoutElementKindSectionHeader = @"INSConferenceLayoutElementKindSectionHeader";
NSString *const INSConferenceLayoutElementKindHourHeader = @"INSConferenceLayoutElementKindHourHeader";
NSString *const INSConferenceLayoutElementKindHalfHourHeader = @"INSConferenceLayoutElementKindHalfHourHeader";

NSString *const INSConferenceLayoutElementKindSectionHeaderBackground = @"INSConferenceLayoutElementKindSectionHeaderBackground";
NSString *const INSConferenceLayoutElementKindHourHeaderBackground = @"INSConferenceLayoutElementKindHourHeaderBackground";

NSString *const INSConferenceLayoutElementKindCurrentTimeIndicator = @"INSConferenceLayoutElementKindCurrentTimeIndicator";
NSString *const INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline = @"INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline";

NSString *const INSConferenceLayoutElementKindVerticalGridline = @"INSConferenceLayoutElementKindVerticalGridline";
NSString *const INSConferenceLayoutElementKindHalfHourVerticalGridline = @"INSConferenceLayoutElementKindHalfHourVerticalGridline";
NSString *const INSConferenceLayoutElementKindHorizontalGridline = @"INSConferenceLayoutElementKindHorizontalGridline";

NSString *const INSConferenceLayoutElementKindFloatingItemOverlay = @"INSConferenceLayoutElementKindFloatingItemOverlay";
NSString *const INSConferenceLayoutElementKindFloatingDayHeader = @"INSConferenceLayoutElementKindFloatingDayHeader";

NSUInteger const INSConferenceLayoutMinOverlayZ = 1000.0;
NSUInteger const INSConferenceLayoutMinCellZ = 100.0;
NSUInteger const INSConferenceLayoutMinBackgroundZ = 0.0;

@interface INSCollectionViewConferenceLayout ()
@property (nonatomic, strong) NSTimer *minuteTimer;
@property (nonatomic, readonly) CGFloat minuteWidth;

@property (nonatomic, assign) BOOL needsToPopulateAttributesForAllSections;

// Registered Decoration Classes
@property (nonatomic, strong) NSMutableDictionary *registeredDecorationClasses;

// Cache
@property (nonatomic, strong) NSCache *cachedStartTimeDateForDays;
@property (nonatomic, strong) NSCache *cachedEndTimeDateForDays;

@property (nonatomic, strong) NSCache *cachedStartTimeDate;
@property (nonatomic, strong) NSCache *cachedEndTimeDate;

@property (nonatomic, strong) NSCache *cachedMaximumDaySectionsWidth;
@property (nonatomic, strong) NSCache *cachedMinimumDaySectionsXCoordinate;

@property (nonatomic, strong) NSDate *cachedCurrentDate;
@property (nonatomic, strong) NSMutableDictionary *cachedFloatingItemsOverlaySize;
@property (nonatomic, strong) NSMutableDictionary *cachedFloatingDayHeaderSize;
@property (nonatomic, assign) NSNumber *cachedNumberOfDays;

@property (nonatomic, strong) NSCache *cachedHours;
@property (nonatomic, strong) NSCache *cachedHalfHours;

// Attributes
@property (nonatomic, strong) NSMutableArray *allAttributes;
@property (nonatomic, strong) NSMutableDictionary *itemAttributes;
@property (nonatomic, strong) NSMutableDictionary *floatingItemAttributes;
@property (nonatomic, strong) NSMutableDictionary *floatingDayHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *sectionHeaderBackgroundAttributes;
@property (nonatomic, strong) NSMutableDictionary *hourHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *halfHourHeaderAttributes;
@property (nonatomic, strong) NSMutableDictionary *hourHeaderBackgroundAttributes;
@property (nonatomic, strong) NSMutableDictionary *horizontalGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *verticalGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *verticalHalfHourGridlineAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentTimeIndicatorAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentTimeVerticalGridlineAttributes;

@end

@implementation INSCollectionViewConferenceLayout

#pragma mark - <INSElectronicProgramGuideLayoutDataSource>

- (id <INSCollectionViewConferenceLayoutDataSource>)dataSource
{
    return (id <INSCollectionViewConferenceLayoutDataSource>)self.collectionView.dataSource;
}

- (void)setDataSource:(id<INSCollectionViewConferenceLayoutDataSource>)dataSource
{
    self.collectionView.dataSource = dataSource;
}

#pragma mark - <INSElectronicProgramGuideLayoutDelegate>

- (id <INSCollectionViewConferenceLayoutDelegate>)delegate
{
    return (id <INSCollectionViewConferenceLayoutDelegate>)self.collectionView.delegate;
}

- (void)setDelegate:(id<INSCollectionViewConferenceLayoutDelegate>)delegate
{
    self.collectionView.delegate = delegate;
}

#pragma mark - NSObject

- (void)dealloc
{
    [self.minuteTimer invalidate];
    self.minuteTimer = nil;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.needsToPopulateAttributesForAllSections = YES;

    self.cachedStartTimeDate = [NSCache new];
    self.cachedEndTimeDate = [NSCache new];
    self.cachedStartTimeDateForDays = [NSCache new];
    self.cachedEndTimeDateForDays = [NSCache new];
    self.cachedFloatingItemsOverlaySize = [NSMutableDictionary new];
    self.cachedFloatingDayHeaderSize = [NSMutableDictionary new];
    self.cachedMaximumDaySectionsWidth = [NSCache new];
    self.cachedMinimumDaySectionsXCoordinate = [NSCache new];
    self.cachedHalfHours = [NSCache new];
    self.cachedHours = [NSCache new];

    self.registeredDecorationClasses = [NSMutableDictionary new];

    self.allAttributes = [NSMutableArray new];
    self.itemAttributes = [NSMutableDictionary new];
    self.floatingItemAttributes = [NSMutableDictionary new];
    self.sectionHeaderAttributes = [NSMutableDictionary new];
    self.sectionHeaderBackgroundAttributes = [NSMutableDictionary new];
    self.hourHeaderAttributes = [NSMutableDictionary new];
    self.halfHourHeaderAttributes = [NSMutableDictionary new];
    self.hourHeaderBackgroundAttributes = [NSMutableDictionary new];
    self.verticalGridlineAttributes = [NSMutableDictionary new];
    self.horizontalGridlineAttributes = [NSMutableDictionary new];
    self.currentTimeIndicatorAttributes = [NSMutableDictionary new];
    self.currentTimeVerticalGridlineAttributes = [NSMutableDictionary new];
    self.verticalHalfHourGridlineAttributes = [NSMutableDictionary new];
    self.floatingDayHeaderAttributes = [NSMutableDictionary new];

    self.shouldUseFloatingDayHeader = YES;
    self.shouldUseFloatingItemOverlay = YES;
    self.daySectionGap = 20;
    self.contentMargin = UIEdgeInsetsMake(0, 0, 0, 0);
    self.cellMargin = UIEdgeInsetsMake(1, 1, 1, 1);
    self.sectionHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 50 : 80;
    self.sectionHeaderWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ?100 : 80;
    self.hourHeaderHeight = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80 : 68;
    self.hourWidth = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 200 : 120;
    self.currentTimeIndicatorSize = CGSizeMake(self.sectionHeaderWidth, 10.0);
    self.currentTimeVerticalGridlineWidth = 1.0;
    self.verticalGridlineWidth = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    self.horizontalGridlineHeight = (([[UIScreen mainScreen] scale] == 2.0) ? 0.5 : 1.0);
    self.sectionGap = 0;
    self.floatingItemOverlaySize = CGSizeMake(0, self.sectionHeight);
    self.floatingItemOffsetFromSection = 0.0;
    self.shouldResizeStickyHeaders = YES;
    self.floatingDayHeaderSize = CGSizeMake(0, self.sectionHeight);

    self.headerLayoutType = INSCollectionViewConferenceLayoutTypeDayColumnAboveTimeRow;

    // Invalidate layout on minute ticks (to update the position of the current time indicator)
    NSDate *oneMinuteInFuture = [[NSDate date] dateByAddingTimeInterval:60];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:oneMinuteInFuture];
    NSDate *nextMinuteBoundary = [[NSCalendar currentCalendar] dateFromComponents:components];

    // This needs to be a weak reference, otherwise we get a retain cycle
    INSTimerWeakTarget *timerWeakTarget = [[INSTimerWeakTarget alloc] initWithTarget:self selector:@selector(minuteTick:)];
    self.minuteTimer = [[NSTimer alloc] initWithFireDate:nextMinuteBoundary interval:60 target:timerWeakTarget selector:timerWeakTarget.fireSelector userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.minuteTimer forMode:NSDefaultRunLoopMode];
}

- (void)invalidateLayoutCache
{
    self.needsToPopulateAttributesForAllSections = YES;

    [self.cachedFloatingItemsOverlaySize removeAllObjects];
    [self.cachedFloatingDayHeaderSize removeAllObjects];

    [self.cachedHours removeAllObjects];
    [self.cachedHalfHours removeAllObjects];

    [self.cachedStartTimeDate removeAllObjects];
    [self.cachedEndTimeDate removeAllObjects];

    self.cachedCurrentDate = nil;
    self.cachedNumberOfDays = nil;

    [self.cachedStartTimeDateForDays removeAllObjects];
    [self.cachedEndTimeDateForDays removeAllObjects];
    [self.cachedMaximumDaySectionsWidth removeAllObjects];
    [self.cachedMinimumDaySectionsXCoordinate removeAllObjects];

    [self.verticalGridlineAttributes removeAllObjects];
    [self.itemAttributes removeAllObjects];
    [self.floatingItemAttributes removeAllObjects];
    [self.sectionHeaderAttributes removeAllObjects];
    [self.sectionHeaderBackgroundAttributes removeAllObjects];
    [self.hourHeaderAttributes removeAllObjects];
    [self.halfHourHeaderAttributes removeAllObjects];
    [self.hourHeaderBackgroundAttributes removeAllObjects];
    [self.horizontalGridlineAttributes removeAllObjects];
    [self.currentTimeIndicatorAttributes removeAllObjects];
    [self.currentTimeVerticalGridlineAttributes removeAllObjects];
    [self.verticalHalfHourGridlineAttributes removeAllObjects];
    [self.floatingDayHeaderAttributes removeAllObjects];
    [self.allAttributes removeAllObjects];
}

#pragma mark - Public

- (NSDate *)dateForHourHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cachedHours objectForKey:indexPath];
}

- (NSDate *)dateForHalfHourHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.cachedHalfHours objectForKey:indexPath];
}

- (void)scrollToCurrentTimeAnimated:(BOOL)animated
{
    if (self.collectionView.numberOfSections > 0) {
        CGRect currentTimeHorizontalGridlineattributesFrame = [self.currentTimeVerticalGridlineAttributes[[NSIndexPath indexPathForItem:0 inSection:0]] frame];
        CGFloat xOffset;
        if (!CGRectEqualToRect(currentTimeHorizontalGridlineattributesFrame, CGRectZero)) {
            xOffset = nearbyintf(CGRectGetMinX(currentTimeHorizontalGridlineattributesFrame) - (CGRectGetWidth(self.collectionView.frame) / 2.0));
        } else {
            xOffset = 0.0;
        }
        CGPoint contentOffset = CGPointMake(xOffset, self.collectionView.contentOffset.y - self.collectionView.contentInset.top);

        // Prevent the content offset from forcing the scroll view content off its bounds
        if (contentOffset.y > (self.collectionView.contentSize.height - self.collectionView.frame.size.height)) {
            contentOffset.y = (self.collectionView.contentSize.height - self.collectionView.frame.size.height);
        }
        if (contentOffset.y < -self.collectionView.contentInset.top) {
            contentOffset.y = -self.collectionView.contentInset.top;
        }
        if (contentOffset.x > (self.collectionView.contentSize.width - self.collectionView.frame.size.width)) {
            contentOffset.x = (self.collectionView.contentSize.width - self.collectionView.frame.size.width);
        }
        if (contentOffset.x < 0.0) {
            contentOffset.x = 0.0;
        }

        [self.collectionView setContentOffset:contentOffset animated:animated];
    }
}

#pragma mark Minute Updates

- (void)minuteTick:(id)sender
{
    // Invalidate cached current date componets (since the minute's changed!)
    self.cachedCurrentDate = nil;
    [self invalidateLayout];
}

#pragma mark - Getters

- (CGFloat)minuteWidth
{
    return self.hourWidth / 60.0;
}

#pragma mark - UICollectionViewLayout

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
{
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (self.registeredDecorationClasses[kind] && !(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:kind withIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewAtIndexPath:(NSIndexPath *)indexPath ofKind:(NSString *)kind withItemCache:(NSMutableDictionary *)itemCache
{
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForCellAtIndexPath:(NSIndexPath *)indexPath withItemCache:(NSMutableDictionary *)itemCache
{
    UICollectionViewLayoutAttributes *layoutAttributes;
    if (!(layoutAttributes = itemCache[indexPath])) {
        layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        itemCache[indexPath] = layoutAttributes;
    }
    return layoutAttributes;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [self invalidateLayoutCache];

    // Update the layout with the new items
    [self prepareLayout];

    [super prepareForCollectionViewUpdates:updateItems];
}

- (void)finalizeCollectionViewUpdates
{
    // This is a hack to prevent the error detailed in :
    // http://stackoverflow.com/questions/12857301/uicollectionview-decoration-and-supplementary-views-can-not-be-moved
    // If this doesn't happen, whenever the collection view has batch updates performed on it, we get multiple instantiations of decoration classes
    for (UIView *subview in self.collectionView.subviews) {
        for (Class decorationViewClass in self.registeredDecorationClasses.allValues) {
            if ([subview isKindOfClass:decorationViewClass]) {
                [subview removeFromSuperview];
            }
        }
    }
    [self.collectionView reloadData];
}

- (void)registerClass:(Class)viewClass forDecorationViewOfKind:(NSString *)decorationViewKind
{
    [super registerClass:viewClass forDecorationViewOfKind:decorationViewKind];
    self.registeredDecorationClasses[decorationViewKind] = viewClass;
}

- (void)registerNib:(UINib *)nib forDecorationViewOfKind:(NSString *)elementKind
{
    [super registerNib:nib forDecorationViewOfKind:elementKind];

    NSArray *topLevelObjects = [nib instantiateWithOwner:nil options:nil];

    NSAssert(topLevelObjects.count == 1 && [[topLevelObjects firstObject] isKindOfClass:UICollectionReusableView.class], @"must contain exactly 1 top level object which is a UICollectionReusableView");

    self.registeredDecorationClasses[elementKind] = [[topLevelObjects firstObject] class];
}

- (void)prepareLayout
{
    [super prepareLayout];

    if (self.needsToPopulateAttributesForAllSections) {
        [self prepareSectionLayoutForSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)]];
        self.needsToPopulateAttributesForAllSections = NO;
    }

    BOOL needsToPopulateAllAttribtues = (self.allAttributes.count == 0);
    if (needsToPopulateAllAttribtues) {
        [self.allAttributes addObjectsFromArray:[self.itemAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.sectionHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.sectionHeaderBackgroundAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.hourHeaderBackgroundAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.hourHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.halfHourHeaderAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.verticalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.horizontalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.currentTimeIndicatorAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.verticalHalfHourGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.currentTimeVerticalGridlineAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.floatingItemAttributes allValues]];
        [self.allAttributes addObjectsFromArray:[self.floatingDayHeaderAttributes allValues]];
    }
}

#pragma mark - Preparing Layout Helpers

- (CGFloat)xCoordinateForDate:(NSDate *)date
{
    for (NSUInteger day = 0; day < self.numberOfDays; day++) {
        NSIndexPath *dayIndexPath = [NSIndexPath indexPathForItem:day inSection:0];

        NSDate *dayStartDate = [self startDateForDayAtIndexPath:dayIndexPath];
        NSDate *dayEndDate = [self endDateForDayAtIndexPath:dayIndexPath];

        if ([dayStartDate ins_isEarlierThanOrEqualTo:date] && [dayEndDate ins_isLaterThanOrEqualTo:date]) {
            CGFloat minimumHourXPosition = [self minimumGridXForDayAtIndexPath:dayIndexPath];

            CGFloat width = nearbyintf(minimumHourXPosition + (date.timeIntervalSince1970 - dayStartDate.timeIntervalSince1970) / 60.0 * self.minuteWidth);

            return width;
        }
    }

    return CGFLOAT_MAX;
}

- (CGFloat)maximumSectionWidthForDayAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedMaximumDaySectionsWidth objectForKey:indexPath]) {
        return [[self.cachedMaximumDaySectionsWidth objectForKey:indexPath] floatValue];
    }

    CGFloat sectionWidth = ([self endDateForDayAtIndexPath:indexPath].timeIntervalSince1970 - [self startDateForDayAtIndexPath:indexPath].timeIntervalSince1970);

    CGFloat maximumWidth =  sectionWidth/ 60.0 * self.minuteWidth;

    [self.cachedMaximumDaySectionsWidth setObject:@(maximumWidth) forKey:indexPath];
    return maximumWidth;
}

- (CGFloat)minimumGridXForDayAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedMinimumDaySectionsXCoordinate objectForKey:indexPath]) {
        return [[self.cachedMinimumDaySectionsXCoordinate objectForKey:indexPath] floatValue];
    }

    CGFloat xCoordinate = [self minimumGridX];

    if (indexPath.row > 0) {
        for (NSUInteger day = 0; day < indexPath.row; day++) {
            xCoordinate += [self maximumSectionWidthForDayAtIndexPath:[NSIndexPath indexPathForItem:day inSection:0]];
            xCoordinate += self.daySectionGap;
        }
    }


    [self.cachedMinimumDaySectionsXCoordinate setObject:@(xCoordinate) forKey:indexPath];

    return xCoordinate;
}

- (CGFloat)minimumGridX
{
    return self.sectionHeaderWidth + self.contentMargin.left;
}

- (CGFloat)minimumGridY
{
    return self.hourHeaderHeight + self.contentMargin.top + self.collectionView.contentInset.top;
}

#pragma mark - Preparing Layout

- (void)prepareSectionLayoutForSections:(NSIndexSet *)sectionIndexes
{
    if (self.collectionView.numberOfSections == 0) {
        return;
    }

    BOOL needsToPopulateItemAttributes = (self.itemAttributes.count == 0);
    BOOL needsToPopulateHorizontalGridlineAttributes = (self.horizontalGridlineAttributes.count == 0);

    [self prepareSectionHeaderBackgroundAttributes];
    [self prepareHourHeaderBackgroundAttributes];

    [self prepareCurrentIndicatorAttributes];

    [self prepareVerticalGridlineAttributes];

    // Prepare first line if not resizing layout headers
    if (needsToPopulateHorizontalGridlineAttributes && !self.shouldResizeStickyHeaders) {
        [self prepareHorizontalGridlineAttributesForSection:0];
    }

    [sectionIndexes enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        [self prepareSectionAttributes:section needsToPopulateItemAttributes:needsToPopulateItemAttributes];

        if (needsToPopulateHorizontalGridlineAttributes) {
            [self prepareHorizontalGridlineAttributesForSection:section+1];
        }
    }];

    if (self.shouldUseFloatingDayHeader) {
        [self prepareFloatingDayHeaders];
    }

}

- (void)prepareFloatingDayHeaders
{
    CGFloat hourMinY = (self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.y + self.collectionView.contentInset.top, 0.0) : self.collectionView.contentOffset.y + self.collectionView.contentInset.top);

    CGFloat floatingGridCenterX = fmaxf(self.collectionView.contentOffset.x, 0.0) + self.collectionView.bounds.size.width/2;

    for (NSUInteger day = 0; day < self.numberOfDays; day++) {
        NSIndexPath *floatingDayHeaderIndexPath = [NSIndexPath indexPathForItem:day inSection:0];

        UICollectionViewLayoutAttributes *floatingDayHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:floatingDayHeaderIndexPath ofKind:INSConferenceLayoutElementKindFloatingDayHeader withItemCache:self.floatingDayHeaderAttributes];

        CGSize floatingItemSize = [self floatingDayHeaderSizeForIndexPath:floatingDayHeaderIndexPath];

        CGFloat sectionMinX = [self minimumGridXForDayAtIndexPath:floatingDayHeaderIndexPath];
        CGFloat sectionMaxX = sectionMinX + [self maximumSectionWidthForDayAtIndexPath:floatingDayHeaderIndexPath];

        if (sectionMinX + floatingItemSize.width/2 > floatingGridCenterX) {
            floatingDayHeaderAttributes.frame = (CGRect){ {sectionMinX, hourMinY}, floatingItemSize };
        } else if (sectionMaxX - floatingItemSize.width/2 < floatingGridCenterX) {
            floatingDayHeaderAttributes.frame = (CGRect){ {sectionMaxX - floatingItemSize.width, hourMinY}, floatingItemSize };
        } else {
            floatingDayHeaderAttributes.frame = (CGRect){ {floatingGridCenterX - floatingItemSize.width/2, hourMinY}, floatingItemSize };
        }

        floatingDayHeaderAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindFloatingDayHeader floating:YES];
    }
}

- (void)prepareHorizontalGridlineAttributesForSection:(NSUInteger)section
{
    CGFloat gridMinY = self.hourHeaderHeight + self.contentMargin.top;

    for (NSUInteger day = 0; day < self.numberOfDays; day++) {
        NSIndexPath *dayIndexPath = [NSIndexPath indexPathForItem:day inSection:0];

        CGFloat horizontalGridlineMinX = [self minimumGridXForDayAtIndexPath:dayIndexPath];
        CGFloat gridWidth = [self maximumSectionWidthForDayAtIndexPath:dayIndexPath];

        CGFloat horizontalGridlineMinY = gridMinY + ((self.sectionHeight + self.sectionGap) * section) - nearbyintf(self.sectionGap/2);

        horizontalGridlineMinY -= self.horizontalGridlineHeight/2;

        NSIndexPath *horizontalGridlineIndexPath = [NSIndexPath indexPathForItem:section inSection:day];
        UICollectionViewLayoutAttributes *horizontalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:horizontalGridlineIndexPath ofKind:INSConferenceLayoutElementKindHorizontalGridline withItemCache:self.horizontalGridlineAttributes];
        horizontalGridlineAttributes.frame = CGRectMake(horizontalGridlineMinX, horizontalGridlineMinY, gridWidth, self.horizontalGridlineHeight);
        horizontalGridlineAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindHorizontalGridline];

    }

}

- (void)prepareVerticalGridlineAttributes
{
    CGFloat hourWidth = self.hourWidth;
    CGFloat hourMinY = (self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.y + self.collectionView.contentInset.top, 0.0) : self.collectionView.contentOffset.y + self.collectionView.contentInset.top);

    CGFloat verticalGridlineMinY = [self minimumGridY] - self.collectionView.contentInset.top;

    CGFloat gridHeight = self.collectionViewContentSize.height - verticalGridlineMinY - self.contentMargin.bottom;

    NSUInteger verticalGridlineIndex = 0;
    NSInteger verticalHalfHourGridlineIndex = 0;

    for (NSUInteger day = 0; day < self.numberOfDays; day++) {
        NSIndexPath *dayIndexPath = [NSIndexPath indexPathForItem:day inSection:0];

        CGFloat minimumHourXPosition = [self minimumGridXForDayAtIndexPath:dayIndexPath];
        CGFloat maximumDaySectionWidth = [self maximumSectionWidthForDayAtIndexPath:dayIndexPath];

        NSUInteger hoursSinceStartDate = 0;
        NSDate *dayStartDate = [self startDateForDayAtIndexPath:dayIndexPath];

        // Hours lines
        for (CGFloat hourX = minimumHourXPosition; hourX <= (minimumHourXPosition + maximumDaySectionWidth); hourX += hourWidth) {
            NSIndexPath *verticalGridlineIndexPath = [NSIndexPath indexPathForItem:verticalGridlineIndex inSection:day];
            UICollectionViewLayoutAttributes *verticalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalGridlineIndexPath ofKind:INSConferenceLayoutElementKindVerticalGridline withItemCache:self.verticalGridlineAttributes];

            verticalGridlineAttributes.frame = CGRectMake(nearbyintf(hourX - self.verticalGridlineWidth/2), verticalGridlineMinY, self.verticalGridlineWidth, gridHeight);
            verticalGridlineAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindVerticalGridline];

            NSIndexPath *hourHeaderIndexPath = [NSIndexPath indexPathForItem:verticalGridlineIndex inSection:day];

            CGFloat hourTimeInterval = 3600;
            if (![self.cachedHours objectForKey:hourHeaderIndexPath]) {
                [self.cachedHours setObject:[dayStartDate dateByAddingTimeInterval: hourTimeInterval * hoursSinceStartDate] forKey:hourHeaderIndexPath];
            }

            UICollectionViewLayoutAttributes *hourHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:hourHeaderIndexPath ofKind:INSConferenceLayoutElementKindHourHeader withItemCache:self.hourHeaderAttributes];
            CGFloat hourHeaderMinX = nearbyintf(hourX - (self.hourWidth / 2.0));

            hourHeaderAttributes.frame = (CGRect){ {hourHeaderMinX, hourMinY}, {self.hourWidth, self.hourHeaderHeight} };
            hourHeaderAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindHourHeader floating:YES];
            
            verticalGridlineIndex++;
            hoursSinceStartDate++;
        }

        hoursSinceStartDate = 0;
        // Half hours lines
        for (CGFloat halfHourX = minimumHourXPosition + hourWidth/2; halfHourX <= minimumHourXPosition + maximumDaySectionWidth; halfHourX += hourWidth) {

            NSIndexPath *verticalHalfHourGridlineIndexPath = [NSIndexPath indexPathForItem:verticalHalfHourGridlineIndex inSection:day];
            UICollectionViewLayoutAttributes *verticalHalfHourGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:verticalHalfHourGridlineIndexPath ofKind:INSConferenceLayoutElementKindHalfHourVerticalGridline withItemCache:self.verticalHalfHourGridlineAttributes];

            verticalHalfHourGridlineAttributes.frame = CGRectMake(nearbyintf(halfHourX - self.verticalGridlineWidth/2), verticalGridlineMinY, self.verticalGridlineWidth, gridHeight);
            verticalHalfHourGridlineAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindHalfHourVerticalGridline];

            NSIndexPath *halfHourHeaderIndexPath = [NSIndexPath indexPathForItem:verticalHalfHourGridlineIndex inSection:day];

            CGFloat hourTimeInterval = 3600;
            if (![self.cachedHalfHours objectForKey:halfHourHeaderIndexPath]) {
                [self.cachedHalfHours setObject:[dayStartDate dateByAddingTimeInterval:hourTimeInterval * hoursSinceStartDate + hourTimeInterval/2] forKey:halfHourHeaderIndexPath];
            }

            UICollectionViewLayoutAttributes *halfHourHeaderAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:halfHourHeaderIndexPath ofKind:INSConferenceLayoutElementKindHalfHourHeader withItemCache:self.halfHourHeaderAttributes];
            CGFloat hourHeaderMinX = nearbyintf(halfHourX - (self.hourWidth / 2.0));
            halfHourHeaderAttributes.frame = (CGRect){ {hourHeaderMinX, hourMinY}, {self.hourWidth, self.hourHeaderHeight} };
            halfHourHeaderAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindHalfHourHeader floating:YES];
            
            verticalHalfHourGridlineIndex++;
            hoursSinceStartDate++;
        }
    }

}

- (void)prepareCurrentIndicatorAttributes
{
    NSIndexPath *currentTimeIndicatorIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *currentTimeIndicatorAttributes = [self layoutAttributesForDecorationViewAtIndexPath:currentTimeIndicatorIndexPath ofKind:INSConferenceLayoutElementKindCurrentTimeIndicator withItemCache:self.currentTimeIndicatorAttributes];

    NSIndexPath *currentTimeHorizontalGridlineIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *currentTimeHorizontalGridlineAttributes = [self layoutAttributesForDecorationViewAtIndexPath:currentTimeHorizontalGridlineIndexPath ofKind:INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline withItemCache:self.currentTimeVerticalGridlineAttributes];

    NSDate *currentDate = [self currentDate];
    CGFloat xCoordinateForCurrentDate = [self xCoordinateForDate:currentDate];
    BOOL currentTimeIndicatorVisible = xCoordinateForCurrentDate != CGFLOAT_MAX;

    currentTimeIndicatorAttributes.hidden = !currentTimeIndicatorVisible;
    currentTimeHorizontalGridlineAttributes.hidden = !currentTimeIndicatorVisible;

    if (currentTimeIndicatorVisible) {

        CGFloat currentTimeIndicatorMinX = xCoordinateForCurrentDate - nearbyintf(self.currentTimeIndicatorSize.width / 2.0);
        CGFloat currentTimeIndicatorMinY = ( self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.y, 0.0) : self.collectionView.contentOffset.y + (self.hourHeaderHeight - self.currentTimeIndicatorSize.height)) + self.collectionView.contentInset.top;
        currentTimeIndicatorAttributes.frame = (CGRect){ {currentTimeIndicatorMinX, currentTimeIndicatorMinY}, self.currentTimeIndicatorSize };
        currentTimeIndicatorAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindCurrentTimeIndicator floating:YES];

        CGFloat currentTimeVerticalGridlineMinY = (self.shouldResizeStickyHeaders ? fmaxf([self minimumGridY], self.collectionView.contentOffset.y + [self minimumGridY]) : self.collectionView.contentOffset.y + [self minimumGridY]);

        CGFloat gridHeight = (self.collectionViewContentSize.height + currentTimeVerticalGridlineMinY);

        currentTimeHorizontalGridlineAttributes.frame = (CGRect){ {xCoordinateForCurrentDate - self.currentTimeVerticalGridlineWidth/2, currentTimeVerticalGridlineMinY}, {self.currentTimeVerticalGridlineWidth, gridHeight} };
        currentTimeHorizontalGridlineAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline];
    }
}

- (void)prepareFloatingItemAttributesOverlayForSection:(NSUInteger)section sectionFrame:(CGRect)rect
{
    CGFloat floatingGridMinX = fmaxf(self.collectionView.contentOffset.x, 0.0) + self.sectionHeaderWidth + self.floatingItemOffsetFromSection;

    for (NSUInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {

        NSIndexPath *floatingItemIndexPath = [NSIndexPath indexPathForRow:item inSection:section];
        UICollectionViewLayoutAttributes *itemAttributes = [self.itemAttributes objectForKey:floatingItemIndexPath];
        CGRect itemAttributesFrame = itemAttributes.frame;
//        itemAttributesFrame.origin.y -= self.cellMargin.top;

        UICollectionViewLayoutAttributes *floatingItemAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:floatingItemIndexPath ofKind:INSConferenceLayoutElementKindFloatingItemOverlay withItemCache:self.floatingItemAttributes];

        CGSize floatingItemSize = [self floatingItemOverlaySizeForIndexPath:floatingItemIndexPath];

        if (floatingItemSize.width >= itemAttributesFrame.size.width) {
            floatingItemAttributes.frame = itemAttributesFrame;
        } else {
            // Items on the right side of sections
            if (itemAttributesFrame.origin.x >= floatingGridMinX) {
                floatingItemAttributes.frame = (CGRect){ itemAttributesFrame.origin, floatingItemSize };
            } else {
                CGFloat floatingSpace = itemAttributesFrame.size.width - floatingItemSize.width;

                floatingItemAttributes.frame = (CGRect){ {itemAttributesFrame.origin.x + floatingSpace, itemAttributesFrame.origin.y} , floatingItemSize};

                //Floating
                if (floatingGridMinX <= floatingItemAttributes.frame.origin.x && floatingGridMinX >= itemAttributesFrame.origin.x) {
                    floatingItemAttributes.frame = (CGRect){ {floatingGridMinX, floatingItemAttributes.frame.origin.y} , floatingItemSize};
                }

            }
        }
        floatingItemAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindFloatingItemOverlay floating:YES];
    }
}

- (void)prepareItemAttributesForSection:(NSUInteger)section sectionFrame:(CGRect)rect
{
    for (NSUInteger item = 0; item < [self.collectionView numberOfItemsInSection:section]; item++) {
        NSIndexPath *itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];

        NSDate *itemStartTime = [self startDateForIndexPath:itemIndexPath];
        NSDate *itemEndTime = [self endDateForIndexPath:itemIndexPath];

        CGFloat itemStartTimePositionX = [self xCoordinateForDate:itemStartTime];
        CGFloat itemEndTimePositionX = [self xCoordinateForDate:itemEndTime];

        if (itemStartTimePositionX != CGFLOAT_MAX && itemEndTimePositionX != CGFLOAT_MAX) {
            UICollectionViewLayoutAttributes *itemAttributes = [self layoutAttributesForCellAtIndexPath:itemIndexPath withItemCache:self.itemAttributes];

            CGFloat itemWidth = itemEndTimePositionX - itemStartTimePositionX;

            itemAttributes.frame = CGRectMake(itemStartTimePositionX + self.cellMargin.left, rect.origin.y + self.cellMargin.top, itemWidth - self.cellMargin.left - self.cellMargin.right, rect.size.height - self.cellMargin.top - self.cellMargin.bottom);
            itemAttributes.zIndex = [self zIndexForElementKind:nil];
        }

    }
}

- (void)prepareSectionAttributes:(NSUInteger)section needsToPopulateItemAttributes:(BOOL)needsToPopulateItemAttributes
{
    CGFloat sectionMinY = self.hourHeaderHeight + self.contentMargin.top;

    CGFloat sectionMinX = self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.x, 0.0) : self.collectionView.contentOffset.x;

    CGFloat sectionY = sectionMinY + ((self.sectionHeight + self.sectionGap) * section);
    NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
    UICollectionViewLayoutAttributes *sectionAttributes = [self layoutAttributesForSupplementaryViewAtIndexPath:sectionIndexPath ofKind:INSConferenceLayoutElementKindSectionHeader withItemCache:self.sectionHeaderAttributes];
    sectionAttributes.frame = CGRectMake(sectionMinX, sectionY, self.sectionHeaderWidth, self.sectionHeight);
    sectionAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindSectionHeader floating:YES];

    if (needsToPopulateItemAttributes) {
        [self prepareItemAttributesForSection:section sectionFrame:sectionAttributes.frame];
    }
    if (self.shouldUseFloatingItemOverlay) {
        [self prepareFloatingItemAttributesOverlayForSection:section sectionFrame:sectionAttributes.frame];
    }
}

- (void)prepareSectionHeaderBackgroundAttributes
{
    CGFloat sectionHeaderMinX = self.shouldResizeStickyHeaders ? fmaxf(self.collectionView.contentOffset.x, 0.0) : self.collectionView.contentOffset.x;

    NSIndexPath *sectionHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UICollectionViewLayoutAttributes *sectionHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:sectionHeaderBackgroundIndexPath ofKind:INSConferenceLayoutElementKindSectionHeaderBackground withItemCache:self.sectionHeaderBackgroundAttributes];

    CGFloat sectionHeaderBackgroundHeight = self.collectionView.frame.size.height - self.collectionView.contentInset.top;
    CGFloat sectionHeaderBackgroundWidth = self.collectionView.frame.size.width;
    CGFloat sectionHeaderBackgroundMinX = (sectionHeaderMinX - sectionHeaderBackgroundWidth + self.sectionHeaderWidth);

    CGFloat sectionHeaderBackgroundMinY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
    sectionHeaderBackgroundAttributes.frame = CGRectMake(sectionHeaderBackgroundMinX, sectionHeaderBackgroundMinY, sectionHeaderBackgroundWidth, sectionHeaderBackgroundHeight);

    sectionHeaderBackgroundAttributes.hidden = NO;
    sectionHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindSectionHeaderBackground floating:YES];
}

- (void)prepareHourHeaderBackgroundAttributes
{

    for (NSUInteger day = 0; day < self.numberOfDays; day++) {
        NSIndexPath *dayIndexPath = [NSIndexPath indexPathForItem:day inSection:0];

        CGFloat horizontalGridlineMinX = [self minimumGridXForDayAtIndexPath:dayIndexPath];
        CGFloat gridWidth = [self maximumSectionWidthForDayAtIndexPath:dayIndexPath] + self.verticalGridlineWidth;

        NSIndexPath *hourHeaderBackgroundIndexPath = [NSIndexPath indexPathForRow:0 inSection:day];
        UICollectionViewLayoutAttributes *hourHeaderBackgroundAttributes = [self layoutAttributesForDecorationViewAtIndexPath:hourHeaderBackgroundIndexPath ofKind:INSConferenceLayoutElementKindHourHeaderBackground withItemCache:self.hourHeaderBackgroundAttributes];
        // Frame
        CGFloat hourHeaderBackgroundHeight = (self.hourHeaderHeight + ((self.collectionView.contentOffset.y < 0.0) ? fabs(self.collectionView.contentOffset.y) : 0.0)) - self.collectionView.contentInset.top;

        if (!self.shouldResizeStickyHeaders || self.hourHeaderHeight >= hourHeaderBackgroundHeight) {
            hourHeaderBackgroundHeight = self.hourHeaderHeight;
        }

        hourHeaderBackgroundAttributes.frame = (CGRect){{horizontalGridlineMinX, self.collectionView.contentOffset.y + self.collectionView.contentInset.top}, {gridWidth, hourHeaderBackgroundHeight}};

        hourHeaderBackgroundAttributes.hidden = NO;
        hourHeaderBackgroundAttributes.zIndex = [self zIndexForElementKind:INSConferenceLayoutElementKindHourHeaderBackground floating:YES];
    }
}

#pragma mark - Layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemAttributes[indexPath];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == INSConferenceLayoutElementKindSectionHeader) {
        return self.sectionHeaderAttributes[indexPath];

    }else if (kind == INSConferenceLayoutElementKindHourHeader) {
        return self.hourHeaderAttributes[indexPath];

    } else if (kind == INSConferenceLayoutElementKindHalfHourHeader) {
        return self.halfHourHeaderAttributes[indexPath];

    } else if (kind == INSConferenceLayoutElementKindFloatingItemOverlay) {
        return self.floatingItemAttributes[indexPath];
    } else if (kind == INSConferenceLayoutElementKindFloatingDayHeader) {

        return self.floatingDayHeaderAttributes[indexPath];
    }

    return nil;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    if (decorationViewKind == INSConferenceLayoutElementKindCurrentTimeIndicator) {
        return self.currentTimeIndicatorAttributes[indexPath];
    }
    else if (decorationViewKind == INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline) {
        return self.currentTimeVerticalGridlineAttributes[indexPath];
    }
    else if (decorationViewKind == INSConferenceLayoutElementKindVerticalGridline) {
        return self.verticalGridlineAttributes[indexPath];
    }
    else if (decorationViewKind == INSConferenceLayoutElementKindHorizontalGridline) {
        return self.horizontalGridlineAttributes[indexPath];
    }
    else if (decorationViewKind == INSConferenceLayoutElementKindHourHeaderBackground) {
        return self.hourHeaderBackgroundAttributes[indexPath];
    }
    else if (decorationViewKind == INSConferenceLayoutElementKindSectionHeaderBackground) {
        return self.hourHeaderBackgroundAttributes[indexPath];

    } else if (decorationViewKind == INSConferenceLayoutElementKindHalfHourVerticalGridline) {
        return self.verticalHalfHourGridlineAttributes[indexPath];
    }
    return nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableIndexSet *visibleSections = [NSMutableIndexSet indexSet];
    [[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collectionView.numberOfSections)] enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
        CGRect sectionRect = [self rectForSection:section];
        if (CGRectIntersectsRect(sectionRect, rect)) {
            [visibleSections addIndex:section];
        }
    }];

    // Update layout for only the visible sections
    [self prepareSectionLayoutForSections:visibleSections];

    // Return the visible attributes (rect intersection)
    return [self.allAttributes filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *layoutAttributes, NSDictionary *bindings) {
        return CGRectIntersectsRect(layoutAttributes.frame,rect);
    }]];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    // Required for sticky headers
    return YES;
}

- (CGSize)collectionViewContentSize
{
    CGFloat width = self.sectionHeaderWidth + self.contentMargin.left + self.contentMargin.right;

    if (self.numberOfDays > 0) {
        NSIndexPath *lastDayIndexPath = [NSIndexPath indexPathForItem:self.numberOfDays-1 inSection:0];
        width = [self minimumGridXForDayAtIndexPath:lastDayIndexPath] + [self maximumSectionWidthForDayAtIndexPath:lastDayIndexPath] + self.verticalGridlineWidth;
    }

    CGFloat height = self.hourHeaderHeight + (((self.sectionHeight + self.sectionGap) * self.collectionView.numberOfSections)) + self.contentMargin.top + self.contentMargin.bottom - (self.sectionGap/2);

    return CGSizeMake(width, height);
}


#pragma mark Section Sizing

- (CGRect)rectForSection:(NSInteger)section
{
    CGFloat sectionHeight = self.sectionHeight;
    CGFloat sectionY = self.contentMargin.top + self.hourHeaderHeight + ((sectionHeight + self.sectionGap) * section);
    return CGRectMake(0.0, sectionY, self.collectionViewContentSize.width, sectionHeight);
}

#pragma mark Z Index

- (CGFloat)zIndexForElementKind:(NSString *)elementKind
{
    return [self zIndexForElementKind:elementKind floating:NO];
}

- (CGFloat)zIndexForElementKind:(NSString *)elementKind floating:(BOOL)floating
{
    if (elementKind == INSConferenceLayoutElementKindCurrentTimeIndicator) {
        return (INSConferenceLayoutMinOverlayZ + ((self.headerLayoutType == INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn) ? (floating ? 9.0 : 4.0) : (floating ? 7.0 : 2.0)));
    }
    else if (elementKind == INSConferenceLayoutElementKindHourHeader || elementKind == INSConferenceLayoutElementKindHalfHourHeader) {
        return (INSConferenceLayoutMinOverlayZ + ((self.headerLayoutType == INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn) ? (floating ? 8.0 : 3.0) : (floating ? 6.0 : 1.0)));
    }
    else if (elementKind == INSConferenceLayoutElementKindHourHeaderBackground) {
        return (INSConferenceLayoutMinOverlayZ + ((self.headerLayoutType == INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn) ? (floating ? 7.0 : 2.0) : (floating ? 5.0 : 0.0)));
    }
    else if (elementKind == INSConferenceLayoutElementKindSectionHeader) {
        return (INSConferenceLayoutMinOverlayZ + ((self.headerLayoutType == INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn) ? (floating ? 6.0 : 1.0) : (floating ? 9.0 : 4.0)));
    }
    else if (elementKind == INSConferenceLayoutElementKindSectionHeaderBackground) {
        return (INSConferenceLayoutMinOverlayZ + ((self.headerLayoutType == INSCollectionViewConferenceLayoutTypeTimeRowAboveDayColumn) ? (floating ? 5.0 : 0.0) : (floating ? 8.0 : 3.0)));
    }
    // Cell
    else if (elementKind == nil) {
        return INSConferenceLayoutMinCellZ;
    }
    // Floating Cell Overlay
    else if (elementKind == INSConferenceLayoutElementKindFloatingItemOverlay) {
        return INSConferenceLayoutMinCellZ + 1.0;
    }
    // Current Time Horizontal Gridline
    else if (elementKind == INSConferenceLayoutElementKindCurrentTimeIndicatorVerticalGridline) {
        return (INSConferenceLayoutMinBackgroundZ + 2.0);
    }
    // Vertical Gridline
    else if (elementKind == INSConferenceLayoutElementKindVerticalGridline || elementKind == INSConferenceLayoutElementKindHalfHourVerticalGridline) {
        return (INSConferenceLayoutMinBackgroundZ + 1.0);
    }
    // Horizontal Gridline
    else if (elementKind == INSConferenceLayoutElementKindHorizontalGridline) {
        return INSConferenceLayoutMinBackgroundZ;
    } else if (elementKind == INSConferenceLayoutElementKindFloatingDayHeader) {
        return [self zIndexForElementKind:INSConferenceLayoutElementKindHourHeader floating:floating];
    }

    return CGFLOAT_MIN;
}

#pragma mark Delegate Wrappers

- (NSDate *)startDateForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedStartTimeDate objectForKey:indexPath]) {
        return [self.cachedStartTimeDate objectForKey:indexPath];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self startTimeForItemAtIndexPath:indexPath];

    [self.cachedStartTimeDate setObject:date forKey:indexPath];
    return date;
}

- (NSDate *)endDateForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedEndTimeDate objectForKey:indexPath]) {
        return [self.cachedEndTimeDate objectForKey:indexPath];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self endTimeForItemAtIndexPath:indexPath];

    [self.cachedEndTimeDate setObject:date forKey:indexPath];
    return date;
}

- (NSDate *)currentDate
{
    if (self.cachedCurrentDate) {
        return self.cachedCurrentDate;
    }

    NSDate *date = [self.dataSource currentTimeForCollectionView:self.collectionView layout:self];

    self.cachedCurrentDate = date;
    return date;
}

- (NSDate *)startDateForDayAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedStartTimeDateForDays objectForKey:indexPath]) {
        return [self.cachedStartTimeDateForDays objectForKey:indexPath];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self startTimeForDayAtIndexPath:indexPath];

    [self.cachedStartTimeDateForDays setObject:date forKey:indexPath];
    return date;
}

- (NSDate *)endDateForDayAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedEndTimeDateForDays objectForKey:indexPath]) {
        return [self.cachedEndTimeDateForDays objectForKey:indexPath];
    }

    NSDate *date = [self.dataSource collectionView:self.collectionView layout:self endTimeForDayAtIndexPath:indexPath];

    [self.cachedEndTimeDateForDays setObject:date forKey:indexPath];
    return date;
}

- (NSUInteger)numberOfDays
{
    if (self.cachedNumberOfDays) {
        return [self.cachedNumberOfDays unsignedIntegerValue];
    }

    NSUInteger numberOfDays = [self.dataSource numberOfDaysInCollectionView:self.collectionView layout:self];
    self.cachedNumberOfDays = @(numberOfDays);
    return numberOfDays;
}

#pragma mark - Size Delegate Wrapper

- (CGSize)floatingItemOverlaySizeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedFloatingItemsOverlaySize objectForKey:indexPath]) {
        return [[self.cachedFloatingItemsOverlaySize objectForKey:indexPath] CGSizeValue];
    }
    CGSize floatingItemSize = self.floatingItemOverlaySize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForFloatingItemOverlayAtIndexPath:)]) {
        floatingItemSize = [self.delegate collectionView:self.collectionView layout:self sizeForFloatingItemOverlayAtIndexPath:indexPath];
    }
    [self.cachedFloatingItemsOverlaySize setObject:[NSValue valueWithCGSize:floatingItemSize] forKey:indexPath];
    return floatingItemSize;
}

- (CGSize)floatingDayHeaderSizeForIndexPath:(NSIndexPath *)indexPath
{
    if ([self.cachedFloatingDayHeaderSize objectForKey:indexPath]) {
        return [[self.cachedFloatingDayHeaderSize objectForKey:indexPath] CGSizeValue];
    }

    CGSize floatingHeaderSize = self.floatingDayHeaderSize;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForFloatingDayHeaderAtSection:)]) {
        floatingHeaderSize = [self.delegate collectionView:self.collectionView layout:self sizeForFloatingDayHeaderAtSection:indexPath.section];
    }

    [self.cachedFloatingDayHeaderSize setObject:[NSValue valueWithCGSize:floatingHeaderSize] forKey:indexPath];
    return floatingHeaderSize;

}

@end
