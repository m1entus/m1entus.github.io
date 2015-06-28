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
#import "ESCoursesFileParser.h"
#import "SettingsViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *bestScheduleButton;
@property (nonatomic, strong) ESSchedule *schedule;
@property (nonatomic, strong) ESDataCache *cache;
@property (nonatomic, strong) ESDataCache *cacheForDownloadedFile;
@property (nonatomic, strong) NSURL *lastEneteredURL;
@property (nonatomic, strong) NSNumber *initialTemperature;
@property (nonatomic, strong) NSNumber *freezingTemperature;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cache = [[ESDataCache alloc] initWithLocalFileDataName:ESDataCacheStanfordDataPath];
    self.initialTemperature = @(0.95);
    self.freezingTemperature = @(pow(2, -3));
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bestScheduleButton.hidden = self.cache.bestSchedule == nil;
    if (self.cache.bestSchedule) {
        [self.bestScheduleButton setTitle:[NSString stringWithFormat:@"Best Schedule with quality: %0.4f",[self.cache.bestSchedule.quality doubleValue]] forState:UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"slotViewFromURL"]) {
        ESTimeSlotsViewController *viewController = segue.destinationViewController;
        viewController.schedule = self.schedule;
        viewController.cache = self.cacheForDownloadedFile;
        
    } else if ([segue.identifier isEqualToString:@"slotView"]) {
        ESTimeSlotsViewController *viewController = segue.destinationViewController;
        viewController.schedule = self.schedule;
        viewController.cache = self.cache;
    } else if ([segue.identifier isEqualToString:@"settings"]) {
        UINavigationController *nav = segue.destinationViewController;
        SettingsViewController *viewController = (id)[nav topViewController];
        viewController.initialTemperature = self.initialTemperature;
        viewController.freezingTemperature = self.freezingTemperature;
        __weak typeof(self) weakSelf = self;
        viewController.completionBlock = ^(NSNumber *initialTemperature, NSNumber *freezingTemperature) {
            weakSelf.initialTemperature = initialTemperature;
            weakSelf.freezingTemperature = freezingTemperature;
        };
    }
    
}

- (IBAction)generateScheduleFromURL:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Enter URL Address:"
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter URL Address";
        textField.text = @"https://raw.githubusercontent.com/m1entus/m1entus.github.io/master/pracownia/Source%20Code/ExamScheduling/small5-stu.txt";
//        textField.text = [self.lastEneteredURL absoluteString];
    }];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *urlTextField = alertController.textFields.firstObject;
                                   self.lastEneteredURL = [NSURL URLWithString:urlTextField.text];

                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                   [self downloadScheduleFromURL:self.lastEneteredURL];
                               }];

    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)downloadScheduleFromURL:(NSURL *)URL {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ESCoursesFileParser parseSynchronouslyFileAtURL:URL completionHandler:^(NSArray *students, NSArray *courses, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                
                if (error) {
                    [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    ESDataCache *cache = [[ESDataCache alloc] init];
                    cache.students = [students copy];
                    cache.courses = [courses copy];
                    [self generateScheduleFromCache:cache];
                }
            });
        }];
    });
}

- (void)generateScheduleFromCache:(ESDataCache *)cache {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeDeterminateHorizontalBar;
    HUD.labelText = @"0%";

    ESSimulatedAnnealingMethodology *sa = [[ESSimulatedAnnealingMethodology alloc] initWithDataCache:cache];
    sa.initialTemperature = self.initialTemperature;
    sa.freezingTemperature = self.freezingTemperature;
    [sa solveWithProgress:^(CGFloat progress) {
        HUD.progress = progress;
        HUD.labelText = [NSString stringWithFormat:@"%0.1f%%",progress*100];
    } completionHandler:^(ESSchedule *bestSchedule) {
        [HUD hide:YES];

        if (!cache.bestSchedule || [cache.bestSchedule.quality doubleValue] > [bestSchedule.quality doubleValue]) {
            cache.bestSchedule = bestSchedule;
            [cache save];
        }
        self.cacheForDownloadedFile = cache;
        self.schedule = bestSchedule;
        [self performSegueWithIdentifier:@"slotViewFromURL" sender:nil];
    }];
}

- (IBAction)generateScheduleButtonTapped:(id)sender {
    [self generateScheduleFromCache:self.cache];
}
- (IBAction)useBestScheduleButtonTapped:(id)sender {
    self.schedule = self.cache.bestSchedule;
    [self performSegueWithIdentifier:@"slotView" sender:sender];
}

@end
