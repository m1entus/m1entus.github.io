//
//  ViewController.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "ViewController.h"
#import "ESDataCache.h"
#import "ESSimulatedAnnealingMethodology.h"
#import <MBProgressHUD.h>
#import "ESTimeSlotsViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bestScheduleButton;
@property (nonatomic, strong) ESSchedule *schedule;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bestScheduleButton.hidden = [ESDataCache sharedInstance].bestSchedule == nil;
    if ([ESDataCache sharedInstance].bestSchedule) {
        [self.bestScheduleButton setTitle:[NSString stringWithFormat:@"Best Schedule with quality: %0.4f",[[ESDataCache sharedInstance].bestSchedule.quality doubleValue]] forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ESTimeSlotsViewController *viewController = segue.destinationViewController;
    viewController.schedule = self.schedule;
}

- (IBAction)generateScheduleButtonTapped:(id)sender {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = @"0%";

    ESSimulatedAnnealingMethodology *sa = [[ESSimulatedAnnealingMethodology alloc] init];
    [sa solveWithProgress:^(CGFloat progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%0.1f%%",progress*100];
    } completionHandler:^(ESSchedule *bestSchedule) {
        [HUD hide:YES];

        if (![ESDataCache sharedInstance].bestSchedule || [[ESDataCache sharedInstance].bestSchedule.quality doubleValue] > [bestSchedule.quality doubleValue]) {
            [ESDataCache sharedInstance].bestSchedule = bestSchedule;
            [[ESDataCache sharedInstance] save];
        }

        self.schedule = bestSchedule;
        [self performSegueWithIdentifier:@"slotView" sender:sender];
    }];
}
- (IBAction)useBestScheduleButtonTapped:(id)sender {
    self.schedule = [ESDataCache sharedInstance].bestSchedule;
    [self performSegueWithIdentifier:@"slotView" sender:sender];
}

@end
