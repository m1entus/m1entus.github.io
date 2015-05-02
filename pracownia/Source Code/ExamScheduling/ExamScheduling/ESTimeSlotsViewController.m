//
//  ESTimeSlotsViewController.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 02.05.2015.
//
//

#import "ESTimeSlotsViewController.h"
#import "INSFloatingHeaderView.h"
#import "INSGrildlineView.h"
#import "INSHeaderBackgroundView.h"
#import "INSSectionBackgroundView.h"
#import "INSSectionHeader.h"
#import "INSCollectionViewConferenceLayout.h"
#import "INSCell.h"
#import "INSFloatingView.h"
#import "INSHourHeader.h"
#import "NSDate+INSUtils.h"
#import "ESDataCache.h"
#import "ESStudent.h"
#import <UIColor+MLPFlatColors.h>
#import "UIColor+LightAndDark.h"

@interface ESTimeSlotsViewController () <INSCollectionViewConferenceLayoutDataSource, INSCollectionViewConferenceLayoutDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *students;
@property (nonatomic, strong) NSArray *courses;
@property (nonatomic, strong) NSMutableDictionary *colors;
@end

@implementation ESTimeSlotsViewController

- (INSCollectionViewConferenceLayout *)collectionViewConferenceLayout {
    return (INSCollectionViewConferenceLayout *)self.collectionView.collectionViewLayout;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.colors = [NSMutableDictionary dictionary];
    self.collectionView.directionalLockEnabled = YES;

    self.title = [NSString stringWithFormat:@"Schedule quality: %0.4f",[self.schedule.quality doubleValue]];

    self.students = [[ESDataCache sharedInstance].students sortedArrayUsingComparator:^NSComparisonResult(ESStudent *obj1, ESStudent *obj2) {
        return [obj1.studentId compare:obj2.studentId options:NSNumericSearch];
    }];

    self.collectionViewConferenceLayout.floatingDayHeaderSize = CGSizeMake(100, 20);
    self.collectionViewConferenceLayout.dataSource = self;
    self.collectionViewConferenceLayout.delegate = self;

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([INSCell class])];

    [self.collectionViewConferenceLayout registerClass:INSGrildlineView.class forDecorationViewOfKind:INSConferenceLayoutElementKindVerticalGridline];
    [self.collectionViewConferenceLayout registerClass:INSGrildlineView.class forDecorationViewOfKind:INSConferenceLayoutElementKindHalfHourVerticalGridline];
    [self.collectionViewConferenceLayout registerClass:INSHeaderBackgroundView.class forDecorationViewOfKind:INSConferenceLayoutElementKindHourHeaderBackground];
    [self.collectionViewConferenceLayout registerClass:INSSectionBackgroundView.class forDecorationViewOfKind:INSConferenceLayoutElementKindSectionHeaderBackground];
    [self.collectionViewConferenceLayout registerClass:INSGrildlineView.class forDecorationViewOfKind:INSConferenceLayoutElementKindHorizontalGridline];
    [self.collectionViewConferenceLayout registerNib:[UINib nibWithNibName:NSStringFromClass([INSHourHeader class]) bundle:nil] forDecorationViewOfKind:INSConferenceLayoutElementKindHourHeader];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSFloatingHeaderView class]) bundle:nil] forSupplementaryViewOfKind:INSConferenceLayoutElementKindFloatingDayHeader withReuseIdentifier:NSStringFromClass([INSFloatingHeaderView class])];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSHourHeader class]) bundle:nil] forSupplementaryViewOfKind:INSConferenceLayoutElementKindHourHeader withReuseIdentifier:NSStringFromClass([INSHourHeader class])];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSHourHeader class]) bundle:nil] forSupplementaryViewOfKind:INSConferenceLayoutElementKindHalfHourHeader withReuseIdentifier:NSStringFromClass([INSHourHeader class])];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSSectionHeader class]) bundle:nil] forSupplementaryViewOfKind:INSConferenceLayoutElementKindSectionHeader withReuseIdentifier:NSStringFromClass([INSSectionHeader class])];

    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([INSFloatingView class]) bundle:nil] forSupplementaryViewOfKind:INSConferenceLayoutElementKindFloatingItemOverlay withReuseIdentifier:NSStringFromClass([INSFloatingView class])];

    self.collectionView.alwaysBounceVertical = YES;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.students.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ESStudent *student = self.students[section];
    return student.courses.count;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESStudent *student = self.students[indexPath.section];
    ESCourse *course = student.courses[indexPath.row];
    NSNumber *slotNumber = [self.schedule slotForCourse:course];

    return [NSDate ins_dateInYear:2015 month:06 day:1 hour:[slotNumber integerValue] minute:00];
}


- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ESStudent *student = self.students[indexPath.section];
    ESCourse *course = student.courses[indexPath.row];
    NSNumber *slotNumber = [self.schedule slotForCourse:course];

    return [NSDate ins_dateInYear:2015 month:06 day:1 hour:[slotNumber integerValue]+1 minute:00];
}

- (NSUInteger)numberOfDaysInCollectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)collectionViewLayout
{
    return 1;
}

- (NSDate *)currentTimeForCollectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)collectionViewLayout
{
    return [[NSDate date] dateByAddingTimeInterval:-2600000];;
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout startTimeForDayAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate ins_dateInYear:2015 month:06 day:1 hour:00 minute:00];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout endTimeForDayAtIndexPath:(NSIndexPath *)indexPath
{
    return [NSDate ins_dateInYear:2015 month:06 day:1 hour:14 minute:00];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    INSCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([INSCell class]) forIndexPath:indexPath];

    ESStudent *student = self.students[indexPath.section];
    ESCourse *course = student.courses[indexPath.row];

    if (!self.colors[course.courseId]) {
        self.colors[course.courseId] = [UIColor randomFlatColor];
    }

    cell.color = self.colors[course.courseId];

    return cell;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;
    if (kind == INSConferenceLayoutElementKindHourHeader) {
        INSHourHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([INSHourHeader class]) forIndexPath:indexPath];
        timeRowHeader.hidden = YES;

        view = timeRowHeader;
    } else if (kind == INSConferenceLayoutElementKindHalfHourHeader) {
        INSHourHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([INSHourHeader class]) forIndexPath:indexPath];

        NSDate *hour = [self.collectionViewConferenceLayout dateForHourHeaderAtIndexPath:indexPath];

        timeRowHeader.time = hour;

        view = timeRowHeader;
    } else if (kind == INSConferenceLayoutElementKindSectionHeader) {
        INSSectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([INSSectionHeader class]) forIndexPath:indexPath];
        ESStudent *student = self.students[indexPath.section];
        header.sectionLabel.text = [NSString stringWithFormat:@"Student: %@",student.studentId];
        view = header;
    } else if (kind == INSConferenceLayoutElementKindFloatingItemOverlay) {
        INSFloatingView *view1 = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([INSFloatingView class]) forIndexPath:indexPath];

        ESStudent *student = self.students[indexPath.section];
        ESCourse *course = student.courses[indexPath.row];

        view1.leftLine.backgroundColor = self.colors[course.courseId];
        view1.titleLabel.text = [NSString stringWithFormat:@"Course: %@",course.courseId];
        view1.titleLabel.textColor = [self.colors[course.courseId] darkerColor];

        view = view1;
    } else if (kind == INSConferenceLayoutElementKindFloatingDayHeader) {
        INSFloatingHeaderView *view1 = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([INSFloatingHeaderView class]) forIndexPath:indexPath];

        view1.dayNameLabel.text = @"Schedule";
        view = view1;
    }
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout sizeForFloatingItemOverlayAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(100, electronicProgramGuideLayout.sectionHeight - self.collectionViewConferenceLayout.cellMargin.top - self.collectionViewConferenceLayout.cellMargin.bottom);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(INSCollectionViewConferenceLayout *)electronicProgramGuideLayout sizeForFloatingDayHeaderAtSection:(NSUInteger)section
{
    //    Entry *entry = [[[[self.fetchedResultsController sections] objectAtIndex:section] objects] firstObject];
    return CGSizeMake(100, self.collectionViewConferenceLayout.hourHeaderHeight/2 );
}

@end
